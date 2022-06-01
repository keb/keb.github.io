// This is a Deno Deploy script
// This is not used by the keb.github.io codebase
const FEED_URL = 'https://mas.to/users/keb.rss';
const FIELD_PATTERN = new RegExp('<lastBuildDate.*>((.|\n)*?)<\/lastBuildDate>', 'i');
const ACCESS_TOKEN = Deno.env.get('ACCESS_TOKEN');
const INTERVAL_IN_MINUTES = 10;

let lastBuildDate = null;

function watchFeed() {
    return fetch(FEED_URL).then(r => r.text()).then(xml => {
        const tmp = FIELD_PATTERN.exec(xml);
        
        if (tmp && tmp[1]) {
            const date = new Date(tmp[1]);
            
            if (!lastBuildDate || date > lastBuildDate) {
                lastBuildDate = date;
                console.log('writing comment...');

                fetch(`https://api.github.com/repos/keb/keb.github.io/issues/1/comments`, {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/vnd.github.v3+json',
                        'Authorization': `token ${ACCESS_TOKEN}`
                    },
                    body: JSON.stringify({ body: '🐕' })
                }).then(() => {
                    console.log('comment written!');
                }).catch(e => {
                    console.error('failed to write comment');
                    console.error(e);
                })
            } else {
                console.log('no need to build');
                console.log({date, lastBuildDate});
            }
        }
    });
}

await watchFeed(); // initial run
setInterval(watchFeed, 60000 * INTERVAL_IN_MINUTES);
