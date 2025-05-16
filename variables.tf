variable "region" {
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR para la VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR para la subred pública"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR para la subred privada"
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Zona de disponibilidad"
  default     = "us-east-1a"
}

variable "key_name" {
  description = "Nombre de la clave SSH para la instancia pública"
  type        = string
  default     = "claveuno"

}

variable "key_name2" {
  description = "Nombre de la clave SSH para la instancia privada"
  type        = string
  default     = "clavedos"

}


variable "eip_web_allocation_id" {
  description = "Allocation ID de la Elastic IP para la instancia web"
  type        = string
  default     = "eipalloc-0b4a1b7674dc8a37e"  # Cambia por tu valor real
}

variable "eip_nat_allocation_id" {
  description = "Allocation ID de la Elastic IP para el NAT Gateway"
  type        = string
  default     = "eipalloc-099b4f35ad251eaed"  # Cambia por tu valor real
}



