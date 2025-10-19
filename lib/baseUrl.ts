const baseUrl =
  process.env.NODE_ENV === "production"
    ? process.env.VERCEL_PROJECT_PRODUCTION_URL
      ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
      : process.env.NEXT_PUBLIC_BASE_URL || "https://prepsurg.co.uk"
    : process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000";

export default baseUrl;
