/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverActions: {
      bodySizeLimit: "10mb",
    },
  },
  transpilePackages: [
    "universal-github-app-jwt",
    "@octokit/auth-app",
    "@octokit/core",
  ],
};

export default nextConfig;
