export function hasApiKeySet(config: Record<string, any>) {
  console.log("[hasApiKeySet] Checking config:", config);
  
  const modelNameKeys = Object.keys(config).filter((key) =>
    key.endsWith("ModelName"),
  );
  console.log("[hasApiKeySet] Model name keys:", modelNameKeys);
  
  const enabledProviders = modelNameKeys
    .map((key) => config[key])
    .map((p) => p.split(":")[0]);
  console.log("[hasApiKeySet] Enabled providers:", enabledProviders);

  const apiKeys = config.apiKeys || {};
  console.log("[hasApiKeySet] API keys:", Object.keys(apiKeys));

  const providersRequiringKeys = enabledProviders.filter(
    (provider) => provider !== "lmstudio",
  );
  console.log("[hasApiKeySet] Providers requiring keys:", providersRequiringKeys);

  // No providers enabled means user is using default model: anthropic
  if (providersRequiringKeys.length === 0 && enabledProviders.includes("lmstudio")) {
    console.log("[hasApiKeySet] ✓ Only LM Studio enabled, no keys required");
    return true;
  }

  if (providersRequiringKeys.length === 0 && !apiKeys.anthropicApiKey) {
    console.log("[hasApiKeySet] ✗ No providers enabled and no anthropic key");
    return false;
  }

  if (
    (enabledProviders.includes("anthropic") && !apiKeys.anthropicApiKey) ||
    (enabledProviders.includes("openai") && !apiKeys.openaiApiKey) ||
    (enabledProviders.includes("google-genai") && !apiKeys.googleApiKey)
  ) {
    console.log("[hasApiKeySet] ✗ Missing required API key for enabled provider");
    return false;
  }

  console.log("[hasApiKeySet] ✓ All required API keys present");
  return true;
}
