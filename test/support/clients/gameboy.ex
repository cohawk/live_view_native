defmodule LiveViewNativeTest.GameBoy do
  use LiveViewNative,
    format: :gameboy,
    component: LiveViewNativeTest.GameBoy.Component,
    module_suffix: :GameBoy,
    template_engine: LiveViewNative.Engine
end