provider "aws" {
  
  region  = "us-east-1"
  profile = "mystu"
}
variable "ami_for_web" {
  default = "ami-0f7c0078fba82b98f"
}
variable "key_for_web" {
  default = "Rhel8keystu"
}

#Security Group For SSH and HTTP
resource "aws_security_group" "SecurityGrp"{
  name = "allow Web Ports"
  description = "Allows Alll HTTP traffic"
  ingress{
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  
  }
  ingress{
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = [ "::/0" ]
  }
}

# To create instance foe Website Hosting Using pre-created Image
resource "aws_instance" "web1" {
  ami           = var.ami_for_web
  instance_type = "t2.micro"
  tags = {
    Name = "Nikhil World PHP Server"
  }
  security_groups	= [ "allow Web Ports" ]
  key_name	= var.key_for_web
}

output  "myout-az" {
	value = aws_instance.web1.availability_zone
}
# To create volume for dynamic code
resource "aws_ebs_volume" "ebs_for_html" {
  availability_zone = aws_instance.web1.availability_zone
  size              = 1
  tags = {
    Name = "EBS Volume for HTML code"
  }
}
# To Attach EBS Volume to Instance
resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdd"
  volume_id   = "${ aws_ebs_volume.ebs_for_html.id }"
  instance_id = "${aws_instance.web1.id}"
  force_detach = true
}
resource "aws_s3_bucket" "bucket_images" {
  bucket = "my-static-image-bucket-nik"
  acl    = "private"

  tags = {
    Name        = "Web Data"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_object" "static_object" {
  key        = "someobject.jpg"
  bucket     = "${aws_s3_bucket.bucket_images.id}"
  source     = "C:/Users/Nikhil/Pictures/art-artistic-background-247676 (2).jpg"
  acl = "private"
}
output "s3-origin"{
    value = aws_s3_bucket.bucket_images
}

resource "null_resource" "remotecommands" {
  depends_on = [aws_volume_attachment.ebs_attach, aws_cloudfront_origin_access_identity.origin_access_identity]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("D:/Hybrid Cloud/Keys/Rhel8keystu")
    host     = "${aws_instance.web1.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdd",
      "sudo mount /dev/xvdd /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo yum install git -y",
      "sudo git clone https://github.com/nikhilgoyalkhadria/firstgit.git /var/www/html/",
      "sudo echo '<img src =https://${aws_cloudfront_distribution.cloudfront_s3_distribution.domain_name}/${aws_s3_bucket_object.static_object.key} width=500 height=400 >' >> /var/www/html/index.php",
    ]
    
  }
  provisioner "local-exec" {
     command = "start chrome ${aws_instance.web1.public_ip}"
  }
}

data "aws_iam_policy_document" "iamrulepolicy" {
  depends_on = [ aws_cloudfront_origin_access_identity.origin_access_identity ]
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    resources = ["${aws_s3_bucket.bucket_images.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "bucpol" {
  bucket = aws_s3_bucket.bucket_images.id
  policy = data.aws_iam_policy_document.iamrulepolicy.json
}


resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Some comment"
}
locals {
  s3_origin_id = "myS3Origin-nikhil"
}
output "oia" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity
}
resource "aws_cloudfront_distribution" "cloudfront_s3_distribution" {
  depends_on = [ aws_s3_bucket.bucket_images , aws_cloudfront_origin_access_identity.origin_access_identity ]
  origin {
    domain_name = "${aws_s3_bucket.bucket_images.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "/"

  

  

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
output "cloudfront" {
  value = aws_cloudfront_distribution.cloudfront_s3_distribution
}