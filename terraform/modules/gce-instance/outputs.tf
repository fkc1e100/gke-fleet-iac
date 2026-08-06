output "instance_id" {
  value       = google_compute_instance.vm_instance.instance_id
  description = "GCE Instance ID"
}

output "self_link" {
  value       = google_compute_instance.vm_instance.self_link
  description = "GCE Instance Self Link"
}
