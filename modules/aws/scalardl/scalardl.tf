module "scalardl_blue" {
  source             = "./cluster"
  security_group_ids = [aws_security_group.scalardl.id]
  bastion_ip         = local.bastion_ip
  network_name       = local.network_name

  resource_type             = local.scalardl_resource_type
  resource_count            = local.scalardl_blue_resource_count
  resource_cluster_name     = "blue"
  resource_root_volume_size = local.scalardl_resource_root_volume_size
  triggers                  = local.triggers
  private_key_path          = local.private_key_path
  user_name                 = local.user_name
  subnet_id                 = local.blue_subnet_id
  image_id                  = local.image_id
  key_name                  = local.key_name
  network_dns               = local.network_dns
  scalardl_image_name       = local.scalardl_blue_image_name
  scalardl_image_tag        = local.scalardl_blue_image_tag
  enable_nlb                = local.scalardl_enable_nlb
  replication_factor        = local.scalardl_replication_factor
  enable_tdagent            = local.scalardl_enable_tdagent

  target_group_arn                = aws_lb_target_group.scalardl-lb-target-group[0].arn
  scalardl_target_port            = local.scalardl_target_port
  privileged_target_group_arn     = aws_lb_target_group.scalardl-privileged-lb-target-group[0].arn
  scalardl_privileged_target_port = local.scalardl_privileged_target_port
}

module "scalardl_green" {
  source             = "./cluster"
  security_group_ids = [aws_security_group.scalardl.id]
  bastion_ip         = local.bastion_ip
  network_name       = local.network_name

  resource_type             = local.scalardl_resource_type
  resource_count            = local.scalardl_green_resource_count
  resource_cluster_name     = "green"
  resource_root_volume_size = local.scalardl_resource_root_volume_size
  triggers                  = local.triggers
  private_key_path          = local.private_key_path
  user_name                 = local.user_name
  subnet_id                 = local.green_subnet_id
  image_id                  = local.image_id
  key_name                  = local.key_name
  network_dns               = local.network_dns
  scalardl_image_name       = local.scalardl_green_image_name
  scalardl_image_tag        = local.scalardl_green_image_tag
  enable_nlb                = local.scalardl_enable_nlb
  replication_factor        = local.scalardl_replication_factor
  enable_tdagent            = local.scalardl_enable_tdagent

  target_group_arn                = aws_lb_target_group.scalardl-lb-target-group[0].arn
  scalardl_target_port            = local.scalardl_target_port
  privileged_target_group_arn     = aws_lb_target_group.scalardl-privileged-lb-target-group[0].arn
  scalardl_privileged_target_port = local.scalardl_privileged_target_port
}

resource "aws_security_group" "scalardl" {
  name        = "${local.network_name}-scalardl-nodes"
  description = "Scalar DL Security Rules"
  vpc_id      = local.network_id

  tags = {
    Name = "${local.network_name} Scalar DL"
  }
}

resource "aws_security_group_rule" "scalardl_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [local.network_cidr]

  security_group_id = aws_security_group.scalardl.id
}

resource "aws_security_group_rule" "scalardl_target_port" {
  type        = "ingress"
  from_port   = local.target_port
  to_port     = local.target_port
  protocol    = "tcp"
  cidr_blocks = [local.scalardl_nlb_internal ? local.network_cidr : "0.0.0.0/0"]
  description = "Scalar DL Target Port"

  security_group_id = aws_security_group.scalardl.id
}

resource "aws_security_group_rule" "scalardl_privileged_port" {
  type        = "ingress"
  from_port   = local.privileged_target_port
  to_port     = local.privileged_target_port
  protocol    = "tcp"
  cidr_blocks = [local.scalardl_nlb_internal ? local.network_cidr : "0.0.0.0/0"]
  description = "Scalar DL Privileged Port"

  security_group_id = aws_security_group.scalardl.id
}

resource "aws_security_group_rule" "scalardl_node_exporter" {
  type        = "ingress"
  from_port   = 9100
  to_port     = 9100
  protocol    = "tcp"
  cidr_blocks = [local.network_cidr]
  description = "Scalar DL Prometheus Node Exporter"

  security_group_id = aws_security_group.scalardl.id
}

resource "aws_security_group_rule" "scalardl_cadvisor" {
  type        = "ingress"
  from_port   = 18080
  to_port     = 18080
  protocol    = "tcp"
  cidr_blocks = [local.network_cidr]
  description = "Scalar DL cAdvisor"

  security_group_id = aws_security_group.scalardl.id
}

resource "aws_security_group_rule" "scalardl_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Scalar DL Egress"

  security_group_id = aws_security_group.scalardl.id
}

resource "aws_lb" "scalardl-lb" {
  count              = local.scalardl_enable_nlb ? 1 : 0
  name               = "${local.network_name}-scalardl-lb"
  internal           = local.scalardl_nlb_internal
  load_balancer_type = "network"
  subnets            = [local.nlb_subnet_id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "scalardl-lb-target-group" {
  count    = local.scalardl_enable_nlb ? 1 : 0
  name     = "${local.network_name}-scalardl-tg"
  port     = local.scalardl_target_port
  protocol = "TCP"
  vpc_id   = local.network_id

  health_check {
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_target_group" "scalardl-privileged-lb-target-group" {
  count    = local.scalardl_enable_nlb ? 1 : 0
  name     = "${local.network_name}-scalardl-pr-tg"
  port     = local.scalardl_privileged_target_port
  protocol = "TCP"
  vpc_id   = local.network_id

  health_check {
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_listener" "scalardl-lb-listener" {
  count             = local.scalardl_enable_nlb ? 1 : 0
  load_balancer_arn = aws_lb.scalardl-lb[0].arn
  port              = local.scalardl_listen_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.scalardl-lb-target-group[0].arn
  }
}

resource "aws_lb_listener" "scalardl-privileged-lb-listener" {
  count             = local.scalardl_enable_nlb ? 1 : 0
  load_balancer_arn = aws_lb.scalardl-lb[0].arn
  port              = local.scalardl_privileged_listen_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.scalardl-privileged-lb-target-group[0].arn
  }
}

resource "aws_route53_record" "scalardl-dns-lb" {
  count   = local.scalardl_enable_nlb ? 1 : 0
  zone_id = local.network_dns
  name    = "scalar-lb"
  type    = "A"

  alias {
    name                   = aws_lb.scalardl-lb[0].dns_name
    zone_id                = aws_lb.scalardl-lb[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "scalardl-blue-dns" {
  count   = local.scalardl_blue_resource_count
  zone_id = local.network_dns
  name    = "scalardl-blue-${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [element(module.scalardl_blue.ip, count.index)]
}

resource "aws_route53_record" "scalardl-green-dns" {
  count   = local.scalardl_green_resource_count
  zone_id = local.network_dns
  name    = "scalardl-green-${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [element(module.scalardl_green.ip, count.index)]
}

resource "aws_route53_record" "scalardl-blue-cadvisor-dns-srv" {
  count = local.scalardl_blue_resource_count > 0 ? 1 : 0

  zone_id = local.network_dns
  name    = "_cadvisor._tcp.scalardl-blue"
  type    = "SRV"
  ttl     = "300"
  records = formatlist(
    "0 0 18080 %s.%s",
    aws_route53_record.scalardl-blue-dns.*.name,
    "internal.scalar-labs.com.",
  )
}

resource "aws_route53_record" "scalardl-green-cadvisor-dns-srv" {
  count = local.scalardl_green_resource_count > 0 ? 1 : 0

  zone_id = local.network_dns
  name    = "_cadvisor._tcp.scalardl-green"
  type    = "SRV"
  ttl     = "300"
  records = formatlist(
    "0 0 18080 %s.%s",
    aws_route53_record.scalardl-green-dns.*.name,
    "internal.scalar-labs.com.",
  )
}

resource "aws_route53_record" "scalardl-blue-node-exporter-dns-srv" {
  count = local.scalardl_blue_resource_count > 0 ? 1 : 0

  zone_id = local.network_dns
  name    = "_node-exporter._tcp.scalardl-blue"
  type    = "SRV"
  ttl     = "300"
  records = formatlist(
    "0 0 9100 %s.%s",
    aws_route53_record.scalardl-blue-dns.*.name,
    "internal.scalar-labs.com.",
  )
}

resource "aws_route53_record" "scalardl-green-node-exporter-dns-srv" {
  count = local.scalardl_green_resource_count > 0 ? 1 : 0

  zone_id = local.network_dns
  name    = "_node-exporter._tcp.scalardl-green"
  type    = "SRV"
  ttl     = "300"
  records = formatlist(
    "0 0 9100 %s.%s",
    aws_route53_record.scalardl-green-dns.*.name,
    "internal.scalar-labs.com.",
  )
}

resource "aws_route53_record" "scalardl-service-dns-srv" {
  count   = local.scalardl_green_resource_count > 0 || local.scalardl_blue_resource_count > 0 ? 1 : 0
  zone_id = local.network_dns
  name    = "_scalardl._tcp.scalardl-service"
  type    = "SRV"
  ttl     = "300"
  records = formatlist("0 0 %s %s.%s", local.scalardl_target_port, concat(aws_route53_record.scalardl-blue-dns.*.name, aws_route53_record.scalardl-green-dns.*.name), "internal.scalar-labs.com.")
}
