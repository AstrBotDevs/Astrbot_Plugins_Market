#!/usr/bin/env bash
set -e

node <<'NODE'
const fs = require('fs');

(async function main() {
  const { Octokit } = await import('@octokit/rest');

  const octokit = new Octokit({
    auth: process.env.PAT_TOKEN,
    userAgent: 'AstrBot Plugin Collector v1.0',
    baseUrl: 'https://api.github.com',
  });

  try {
    console.log('Fetching issues with plugin-publish label from astrbotdevs/astrbot...');
    let page = 1;
    let allIssues = [];
    while (true) {
      const { data } = await octokit.rest.issues.listForRepo({
        owner: 'astrbotdevs',
        repo: 'astrbot',
        labels: 'plugin-publish',
        state: 'open',
        per_page: 100,
        page
      });
      if (!data.length) break;
      allIssues = allIssues.concat(data);
      console.log('Fetched page', page, '- found', data.length, 'issues');
      page++;
    }

    console.log('Total found', allIssues.length, 'issues with plugin-publish label');

    const plugins = [];
    const codeBlockRegex = /```(?:json)?\s*([\s\S]*?)\s*```/i;

    for (const issue of allIssues) {
      console.log('Processing issue #' + issue.number + ':', issue.title);
      const body = issue.body || '';
      const jsonMatch = body.match(codeBlockRegex);
      if (jsonMatch) {
        try {
          const jsonStr = jsonMatch[1].trim();
          const pluginInfo = JSON.parse(jsonStr);
          if (pluginInfo.name && pluginInfo.desc && pluginInfo.author && pluginInfo.repo) {
            pluginInfo.issue_number = issue.number;
            pluginInfo.issue_url = issue.html_url;
            pluginInfo.created_at = issue.created_at;
            pluginInfo.updated_at = issue.updated_at;
            if (!pluginInfo.tags) pluginInfo.tags = [];
            if (!pluginInfo.social_link) pluginInfo.social_link = '';
            plugins.push(pluginInfo);
            console.log('✓ Extracted plugin:', pluginInfo.name);
          } else {
            console.log('✗ Missing required fields in issue #' + issue.number);
          }
        } catch (parseError) {
          console.log('✗ Failed to parse JSON in issue #' + issue.number + ':', parseError.message);
        }
      } else {
        console.log('✗ No JSON block found in issue #' + issue.number);
      }
    }

    const result = {
      updated_at: new Date().toISOString(),
      total_plugins: plugins.length,
      plugins: plugins.sort((a, b) => a.name.localeCompare(b.name))
    };

    // 写到仓库根目录 plugin-issue.json
    fs.writeFileSync('plugin-issue.json', JSON.stringify(result, null, 2));
    console.log('✓ Created plugin-issue.json with', plugins.length, 'plugins');

    if (process.env.GITHUB_OUTPUT) {
      fs.appendFileSync(process.env.GITHUB_OUTPUT, `plugins_count=${plugins.length}\n`);
    } else {
      console.log(`plugins_count=${plugins.length}`);
    }
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
})();
NODE


