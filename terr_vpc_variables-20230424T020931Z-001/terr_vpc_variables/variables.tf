variable cidr_block {
default = "192.168.0.0/16"
}
variable tag {
default = "prod"
}
variable subnet1_cidr_block {
default = "192.168.0.0/24"
}
variable availability_zone {
default = "ap-south-1a"
}
variable subnet2_cidr_block {
default = "192.168.2.0/24"
}

variable terraform-key-pair {
default = "amarsampleaug0423"
}

variable ami {
default = "ami-021f7978361c18b01"
}

variable instance_type {
default = "t2.micro"
}

variable availability_zone_1 {
default = "ap-south-1b"
}

variable autoscaling_group_min_size {
default = "2"
}

variable autoscaling_group_max_size {
default = "5"
}



