# creating ami variable
variable "ami" {
  default     = "ami-01b799c439fd5516a"
  description = "value of the ami"
  #type = string # we can remove default and add type. this will prompt the user to enter the value of the variable in the terminal. 
}