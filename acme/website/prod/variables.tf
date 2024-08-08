variable "image" {
  description = "Docker image with the static website files"
  type        = string
}

variable "backend" {
  description = "URL of the backend API for the website"
  type        = string
}

variable "route" {
  description = "URL route to the website"
  type        = string
}