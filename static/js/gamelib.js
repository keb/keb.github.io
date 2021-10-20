(async function(lunr) {
    const GIST_ID = '4369660d49048696510d34cb0e619c56';    

    const $gameLib = document.querySelector('.gamelib');
    const $gameSearchInput = document.querySelector('.gamesearch-input');
    const $gameClearBtn = document.querySelector('.gamesearch-clear');
    const $gameSearchForm = document.querySelector('.gamesearch-form');
    const $gameLibCount = document.querySelector('.gamelib-count');

    let res = await fetch(`https://api.github.com/gists/${GIST_ID}`);
    let json = await res.json();
    
    let library;
    let isError = false;

    try {
        library = JSON.parse(json.files['library.json'].content);
    } catch {
        isError = true;
        console.error('Could not parse JSON.');
    } finally {
        res = undefined;
        json = undefined;
        if (isError) return;
    }

    let allGamesHtml = '';
    let isViewingAllGames = true;
    const allGamesCount = library.count;
    const slugMap = {};

    $gameLibCount.innerText = `${allGamesCount} games`;

    const idx = lunr(function() {
        this.ref('slug');
        this.field('name');
        this.field('store');

        // let's not waste this loop;
        // use it for both the lunr index build and initial HTML build
        let gamesHtml = '';
        for (let i = 0, len = library.games.length; i < len; i++) {
            const slug = slugify(library.games[i].name + library.games[i].store);
            this.add({
                slug: slug,
                name: library.games[i].name,
                store: library.games[i].store
            });

            slugMap[slug] = library.games[i];
            gamesHtml += GameHtml(library.games[i]);
        }

        allGamesHtml = gamesHtml;
        $gameLib.innerHTML = allGamesHtml;
    });

    // $gameClearBtn.addEventListener('click', (ev) => {
    //    ev.preventDefault();
    //    $gameSearchInput.value = '';
    //    if (!isViewingAllGames) $gameLib.innerHTML = allGamesHtml;
    // });

    $gameSearchForm.addEventListener('submit', (ev) => {
        ev.preventDefault();
        const value = $gameSearchInput.value.trim();
        if (value) {
            const results = idx.search(value + '~1');
            console.log(results);
            const games = [];
            for (let i = 0, len = results.length; i < len; i++) {
                games.push(slugMap[results[i].ref]);
            }

            const html = buildGamesHtml(games);
            $gameLib.innerHTML = html.trim() ? html : '<article class="game"><em>No games found</em></article>';
            $gameLibCount.innerText = `${games.length} games`;
            isViewingAllGames = false;
        } else {
            $gameLib.innerHTML = allGamesHtml;
            $gameLibCount.innerText = `${allGamesCount} games`;
            isViewingAllGames = true;
        }
    });

    function buildGamesHtml(games) {
        let gamesHtml = '';
        for (let i = 0, len = games.length; i < len; i++) {
            gamesHtml += GameHtml(games[i]);
        }

        return gamesHtml;
    }

    function GameHtml(game) {
        let header = '';
        if (game.url) {
            header = `<header><a href="${game.url}">${game.name}</a></header>`;
        } else {
            header = `<header>${game.name}</header>`   
        }

        return `<article class="game">` +
            header +
            `<aside>${game.store}</aside>` +
        `</article>`;
    }

    function slugify(text) {
        let lines = text.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const slug = lines[i].toString().toLowerCase()
                .replace(/\s+/g, '-') // Replace spaces with -
                .replace(/[^\w\-]+/g, '') // Remove all non-word chars
                .replace(/\-\-+/g, '-') // Replace multiple - with single -
                .replace(/^-+/, '') // Trim - from start of text
                .replace(/-+$/, '') // Trim - from end of text
            ;

            if (slug.length > 0)
                return slug;
        }

        return '';
    }
})(window.lunr);
