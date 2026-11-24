import type { PluginClientContext } from "@otto-code/plugin/client";
import { PairSurface } from "./client/PairSurface";

export default function contribute(client: PluginClientContext) {
  client.addSurface("otto-host-pair", PairSurface);
  client.addSidebarItem({
    id: "otto-host-pair",
    title: "Otto Host Pair",
    icon: "DeviceHub",
    surface: "otto-host-pair",
  });
  return () => {};
}
