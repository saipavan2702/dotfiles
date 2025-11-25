export default {
  defaultBrowser: "Google Chrome",
  handlers: [
    {
      match: "youtube.com",
      browser: "Brave",
    },
    {
      match: [
        "google.com/*", 
        "*.google.com*", 
      ],
      browser: "Google Chrome",
    },
  ],
};
