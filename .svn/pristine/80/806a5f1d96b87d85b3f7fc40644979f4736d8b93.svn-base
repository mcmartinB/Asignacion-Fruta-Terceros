program AsignacionFrutaTerceros;

uses
  Forms,
  CFAPrincipal in 'CFAPrincipal.pas' {FAPrincipal},
  CDAPrincipal in 'CDAPrincipal.pas' {DAPrincipal: TDataModule},
  CRPSepararLineaSalida in 'CRPSepararLineaSalida.pas' {RPSepararLineaSalida: TQuickRep},
  CDPAsignacionTerceros in 'CDPAsignacionTerceros.pas' {DPAsignacionTerceros: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFAPrincipal, FAPrincipal);
  Application.CreateForm(TDPAsignacionTerceros, DPAsignacionTerceros);
  Application.CreateForm(TRPSepararLineaSalida, RPSepararLineaSalida);
  Application.CreateForm(TDPAsignacionTerceros, DPAsignacionTerceros);
  Application.Run;
end.
