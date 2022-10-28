output "mydomain_zoneid" {
  description = "The Hosted Zone id of the desired Hosted Zone"
  value = data.aws_route53_zone.mydomain.zone_id
}

output "mydomain_name" {
  description = "The Hosted Zone id of the desired Hosted Zone"
  value = data.aws_route53_zone.mydomain.name
}

output "app1_launch_template_id" {
  description = "The ID of the app1 launch template"
  value       = module.app1.launch_template_id
}

output "app1_launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = module.app1.launch_template_latest_version
}

output "app1_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.app1.autoscaling_group_id
}

output "app1_autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.app1.autoscaling_group_name
}

output "app1_autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.app1.autoscaling_group_arn
}

output "app2_launch_template_id" {
  description = "The ID of the app2 launch template"
  value       = module.app2.launch_template_id
}

output "app2_launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = module.app2.launch_template_latest_version
}


output "app2_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.app2.autoscaling_group_id
}

output "app2_autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.app2.autoscaling_group_name
}

output "app2_autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.app2.autoscaling_group_arn
}

output "app3_launch_template_id" {
  description = "The ID of the app3 launch template"
  value       = module.app3.launch_template_id
}

output "app3_launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = module.app3.launch_template_latest_version
}


output "app3_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.app3.autoscaling_group_id
}

output "app3_autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.app3.autoscaling_group_name
}

output "app3_autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.app3.autoscaling_group_arn
}

#ELB-ALB outputs

output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.lb_id
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.lb_arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb.lb_dns_name
}

output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = module.alb.lb_arn_suffix
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = module.alb.lb_zone_id
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_arns
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_ids
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = module.alb.https_listener_arns
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = module.alb.https_listener_ids
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.alb.target_group_arns
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.alb.target_group_arn_suffixes
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.alb.target_group_names
}

output "target_group_attachments" {
  description = "ARNs of the target group attachment IDs."
  value       = module.alb.target_group_attachments
}

output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

