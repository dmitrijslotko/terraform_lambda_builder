variable "default_lambda_runtime" {
    type = string
    default = "nodejs14.x"
}

variable "lambda_runtime" {
    type = string
    default = "nodejs14.x"
}

variable "default_lambda_memory" {
    type = number
    default = 256
}

variable "lambda_memory" {
    type = number
    default = 0
}

variable "default_lambda_timeout" {
    type = number
    default = 30
}

variable "lambda_timeout" {
    type = number
    default = 30
}

variable "default_lambda_handler" {
    type = string
    default = "index.handler"
}

variable "lambda_handler" {
    type = string
    default = ""
}

variable "lambda_role" {
    type = string
    default = ""
}

variable "function_name" {
    type = string
}

variable "file_name" {
    type = string
}

variable "lambda_retention_in_days"{
    type = number
    default = 30
}

variable "default_enviroment_variables"{
    type = map(string) 
    default = {
        layer_prefix = "/opt/nodejs/"
    }
}

variable "enviroment_variables"{
    type = map(string) 
    default = null
}

variable "default_tags"{
    type = map(string) 
    default = null
}

variable "lambda_tags"{
    type = map(string) 
    default = null
}

variable "reserved_concurrent_executions"{
    type = number 
    default = -1
}

variable "layers"{
    type = list(string)
    default = null
}

variable "default_layers"{
    type = list(string)
    default = null
}