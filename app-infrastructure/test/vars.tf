variable "env" {}
variable "appname" { default = "hello" }
variable "db_password" {}
variable "backup_retention_period" { default = "0" }
variable "multi_az" { default = "false" }
variable "backup_window" { default = "02:17-02:47" }
variable "maintenance_window" { default = "Wed:03:55-Wed:04:25" }
variable "allocated_storage" { default = 10 }
variable "db_instance_class" { default = "db.t2.micro" }
variable "storage_type" { default = "gp2" }
variable "apply_immediately" { default = "true" }
