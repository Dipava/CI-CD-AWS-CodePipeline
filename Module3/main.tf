resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "lt-3t.droytech.in"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.1.0"
  zone_id    = data.aws_route53_zone.mydomain.zone_id
  domain_name = trimsuffix(data.aws_route53_zone.mydomain.name, ".")
  subject_alternative_names = ["*.droytech.in"]
  tags = {Name = "acm-droytech"}
}

# ASG for App1, App2 and App3 

# ELB-ALB Module

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"
  name               = "dev-alb"
  load_balancer_type = "application"
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups    = [data.terraform_remote_state.loadbalancer_sg.outputs.loadbalancer_sg_group_id]

  target_groups = [
    #app1 target group -TG Index = 0
    {
      name_prefix          = "app1-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      tags = {Name = "app1-tg"}
    },
    #app2 target group -TG Index = 1
    {
      name_prefix          = "app2-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app2/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      tags = {Name = "app2-tg"}
    },

#app3 target group -TG Index = 2
    {
      name_prefix          = "app3-"
      backend_protocol     = "HTTP"
      backend_port         = 8080
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      stickiness = {
        enabled = true
        cookie_duration = 86400
        type = "lb_cookie"
      } 

      protocol_version = "HTTP1"
      tags = {Name = "app3-tg"}
    }
  ]

# HTTP Listener

  http_tcp_listeners = [
    
    {
      port               = 80
      protocol           = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

# HTTPS Listener Index = 0 for HTTPS 443

https_listeners = [
  {
    port               = 443
    protocol           = "HTTPS"
    certificate_arn    = module.acm.acm_certificate_arn
    action_type = "fixed-response"
    fixed_response = {
      content_type = "text/plain"
      message_body = "Welcome to Droytech"
      status_code  = "200"
    }
  }
] 

# HTTPS Listener Rules

https_listener_rules = [
  # Rule-1: app1.droytech.in should go to app1 ec2 instances
    {
      https_listener_index = 0
      priority = 1

      actions = [
        {
          type = "forward"
          target_group_index = 0
        }
      ]
      conditions = [
        {
        path_patterns = ["/app1*"]
        }]
    },
  # Rule-2: app1.droytech.in should go to app2 ec2 instances
    {
      https_listener_index = 0
      priority = 2

      actions = [
        {
          type = "forward"
          target_group_index = 1
        }
      ]
      conditions = [
        {
        path_patterns = ["/app2*"]
        }
      ]
   },
    # Rule-3: When Query-String, website=aws-eks redirect to https://lt-3t.droytech.in/
    {
      https_listener_index = 0
      priority = 3

      actions = [
        {
          type = "forward"
          target_group_index = 2
        }
      ]
      
      conditions = [
        {
         path_patterns = ["/*"]
        }
     ]
   },
  ]
  
  tags = {Name = "alb-dev"}
}

module "app1" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  # Autoscaling group -app1
  # depends_on = [data.terraform_remote_state.vpc]
  name            = "app1-asg"
  use_name_prefix = false
  instance_name   = "app1-dev"
  security_groups          = [data.terraform_remote_state.private_sg.outputs.private_sg_group_id]
  target_group_arns = module.alb.target_group_arns
  key_name = var.instance_keypair
  ignore_desired_capacity_changes = false
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  vpc_zone_identifier       = data.terraform_remote_state.vpc.outputs.private_subnets
  #service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

  initial_lifecycle_hooks = [
    {
      name                 = "ExampleStartupLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 60
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                 = "ExampleTerminationLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
  triggers = ["desired_capacity"]
  }

  # Launch template
  launch_template_name        = "app1-dev-lt"
  launch_template_description = "Launch template for App1"
  update_default_version      = true
  image_id          = data.aws_ami.amzlinux2.id
  instance_type     = var.instance_type
  user_data         = filebase64("${path.module}/app1-install.sh")
  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 8
        volume_type           = "gp2"
      }
    }
  ]


  # Target scaling policy schedule based on average CPU load
  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 180
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    },
      request-count-per-target = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 120
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ALBRequestCountPerTarget"
          resource_label         = "${module.alb.lb_arn_suffix}/${module.alb.target_group_arn_suffixes[0]}"
        }
        target_value = 10
      }
    }
  }
}
module "app2" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  # Autoscaling group -app2
  # depends_on = [data.terraform_remote_state.vpc]
  name            = "app2-asg"
  use_name_prefix = false
  instance_name   = "app2-dev"
  security_groups          = [data.terraform_remote_state.private_sg.outputs.private_sg_group_id]
  target_group_arns = module.alb.target_group_arns
  key_name = var.instance_keypair
  ignore_desired_capacity_changes = false
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  vpc_zone_identifier       = data.terraform_remote_state.vpc.outputs.private_subnets
  #service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

  initial_lifecycle_hooks = [
    {
      name                 = "ExampleStartupLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 60
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                 = "ExampleTerminationLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
  triggers = ["desired_capacity"]
  }

  # Launch template
  launch_template_name        = "app2-dev-lt"
  launch_template_description = "Launch template for App2"
  update_default_version      = true
  image_id          = data.aws_ami.amzlinux2.id
  instance_type     = var.instance_type
  user_data         = filebase64("${path.module}/app2-install.sh")
  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 8
        volume_type           = "gp2"
      }
    }
  ]


  # Target scaling policy schedule based on average CPU load
  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 180
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    },
      request-count-per-target = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 120
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ALBRequestCountPerTarget"
          resource_label         = "${module.alb.lb_arn_suffix}/${module.alb.target_group_arn_suffixes[0]}"
        }
        target_value = 10
      }
    }
  }
}

module "app3" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  # Autoscaling group -app3
  # depends_on = [data.terraform_remote_state.vpc,data.terraform_remote_state.rdsdb]
  name            = "app3-asg"
  use_name_prefix = false
  instance_name   = "app3-dev"
  security_groups          = [data.terraform_remote_state.private_sg.outputs.private_sg_group_id]
  target_group_arns = module.alb.target_group_arns
  key_name = var.instance_keypair
  ignore_desired_capacity_changes = false
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  vpc_zone_identifier       = data.terraform_remote_state.vpc.outputs.private_subnets
  #service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

  initial_lifecycle_hooks = [
    {
      name                 = "ExampleStartupLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 60
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                 = "ExampleTerminationLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
  triggers = ["desired_capacity"]
  }

  # Launch template
  launch_template_name        = "app3-dev-lt"
  launch_template_description = "Launch template for App3"
  update_default_version      = true
  image_id          = data.aws_ami.amzlinux2.id
  instance_type     = var.instance_type
  user_data         = base64encode(templatefile("app3-ums-install.tmpl",{rds_db_endpoint = data.terraform_remote_state.rdsdb.outputs.db_instance_address}))
  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 8
        volume_type           = "gp2"
      }
    }
  ]


  # Target scaling policy schedule based on average CPU load
  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 180
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    },
      request-count-per-target = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 120
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ALBRequestCountPerTarget"
          resource_label         = "${module.alb.lb_arn_suffix}/${module.alb.target_group_arn_suffixes[0]}"
        }
        target_value = 10
      }
    }
  }
}

## SNS - Topic

resource "random_pet" "this" {
  length = 2
}
 
resource "aws_sns_topic" "app1_sns_topic" {
  name = "app1-sns-topic-${random_pet.this.id}"
}

## SNS - Subscription

resource "aws_sns_topic_subscription" "app1_sns_topic_subscription" {
  topic_arn = aws_sns_topic.app1_sns_topic.arn
  protocol  = "email"
  endpoint  = "dipavanetworklessons22@gmail.com"
}

## Create Autoscaling Notification Resource
 
resource "aws_autoscaling_notification" "app1_notifications" {
  group_names = [module.app1.autoscaling_group_name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.app1_sns_topic.arn
}

resource "aws_sns_topic" "app2_sns_topic" {
  name = "app2-sns-topic-${random_pet.this.id}"
}

## SNS - Subscription

resource "aws_sns_topic_subscription" "app2_sns_topic_subscription" {
  topic_arn = aws_sns_topic.app2_sns_topic.arn
  protocol  = "email"
  endpoint  = "dipavanetworklessons22@gmail.com"
}

## Create Autoscaling Notification Resource
 
resource "aws_autoscaling_notification" "app2_notifications" {
  group_names = [module.app2.autoscaling_group_name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.app2_sns_topic.arn
}

resource "aws_sns_topic" "app3_sns_topic" {
  name = "app3-sns-topic-${random_pet.this.id}"
}

## SNS - Subscription

resource "aws_sns_topic_subscription" "app3_sns_topic_subscription" {
  topic_arn = aws_sns_topic.app3_sns_topic.arn
  protocol  = "email"
  endpoint  = "dipavanetworklessons22@gmail.com"
}

## Create Autoscaling Notification Resource
 
resource "aws_autoscaling_notification" "app3_notifications" {
  group_names = [module.app3.autoscaling_group_name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.app3_sns_topic.arn
}
