output "root_module_directory" {
  description = "The pathname of the root module directory."
  value       = abspath(path.module)
}
