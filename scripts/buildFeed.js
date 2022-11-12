import { readFileSync, writeFileSync } from 'fs';
import { resolve } from 'path';
import Parser from 'rss-parser';

const FEED_URL = 'https://tilde.zone/users/keb.rss';

const parser = new Parser({
  customFields: {
    item: ['media:content', 'media:content', {keepArray: true}],
  }
});

let html = '';

(async () => {
    const feed = await parser.parseURL(FEED_URL);

    for (let item of feed.items) {
        const tmp = item['media:content'];
        const media = tmp ? tmp['$'] : null;
        let mediaHtml = '';

        if (media) {
            const type = media.type.split('/')[0];

            if (type == 'video') {
                mediaHtml =
                    `<video controls preload="metadata" src="${media.url}"></video>`;
            } else if (type == 'image') {
                mediaHtml =
                    `<a href="${media.url}"><img loading="lazy" src="${media.url}" alt="mastodon image" /></a>`;
            }
        }

        const date = new Date(item.pubDate);
        const dateStr = `${date.getFullYear()}.${date.getMonth() + 1}.${date.getDate()}`;

        html += (
            `<article class="feed-item">` +
                `<div class="link"><a href="${item.link}">@ ${dateStr}</a></div>` +
                `<div class="content">${item.content}${mediaHtml}</div>` +
            `</article>`
        );
    }

    writeFileSync(resolve('./templates/_mastodon-feed.html'), html, { encoding: 'utf8' });
})();
