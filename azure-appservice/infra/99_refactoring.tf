
moved {
  from = azurerm_linux_web_app.app_dev
  to   = module.app_dev.azurerm_linux_web_app.this
}

moved {
  from = azurerm_linux_web_app_slot.app_dev_staging
  to   = module.app_dev.azurerm_linux_web_app_slot.staging
}

moved {
  from = azurerm_linux_web_app.app_fakeprod
  to   = module.app_fakeprod.azurerm_linux_web_app.this
}

moved {
  from = azurerm_linux_web_app_slot.app_fakeprod_staging
  to   = module.app_fakeprod.azurerm_linux_web_app_slot.staging
}
