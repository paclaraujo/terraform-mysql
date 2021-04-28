variable "user" {
  type = object({
    name    = string
    password = string
  })
  sensitive = true
}