import type { PluginServerContext } from "@otto-code/plugin/server";
import { registerTailscale } from "./server/tailscale";

export default function contribute(server: PluginServerContext) {
  registerTailscale(server);
  return () => {};
}
