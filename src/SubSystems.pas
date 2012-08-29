unit SubSystems;

interface

uses
  DGLE2;

var
  EngineCore     : IEngineCore = nil;
  ResMan         : IResourceManager = nil;
  Render         : IRender = nil;
  Render2D       : IRender2D = nil;
  Input          : IInput = nil;
  Sound          : ISound;
  MainFileSystem : IMainFileSystem = nil;
  HDDFileSystem  : IFileSystem = nil;
  Particles      : IPlugin = nil;

procedure Init;
procedure Free;

implementation

procedure Init;
begin
  EngineCore.GetSubsystem( ESS_RESOURCE_MANAGER, IEngineSubSystem( ResMan ));
  EngineCore.GetSubsystem( ESS_RENDER, IEngineSubSystem( Render ));
  EngineCore.GetSubsystem( ESS_INPUT, IEngineSubSystem( Input ));
  EngineCore.GetSubsystem( ESS_FILESYSTEM, IEngineSubSystem( MainFileSystem ));
  EngineCore.GetSubsystem( ESS_SOUND, IEngineSubSystem( Sound ));

  Render.GetRender2D( Render2D );
  MainFileSystem.GetVirtualFileSystem( nil, HDDFileSystem );
end;

procedure Free;
begin
  EngineCore     := nil;
  ResMan         := nil;
  Render         := nil;
  Render2D       := nil;
  Input          := nil;
  Sound          := nil;
  MainFileSystem := nil;
  HDDFileSystem  := nil;
  Particles      := nil;
end;

end.
