object DAPrincipal: TDAPrincipal
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 261
  Width = 423
  object DBPrincipal: TDatabase
    AliasName = 'comercializacion'
    DatabaseName = 'DBPrincipal'
    SessionName = 'Default'
    Left = 40
    Top = 48
  end
  object QKilosAprovechados: TQuery
    DatabaseName = 'DBPrincipal'
    Left = 112
    Top = 72
  end
  object QKilosSalida: TQuery
    DatabaseName = 'DBPrincipal'
    Left = 184
    Top = 96
  end
  object QKilosTerceros: TQuery
    DatabaseName = 'DBPrincipal'
    Left = 240
    Top = 120
  end
end
