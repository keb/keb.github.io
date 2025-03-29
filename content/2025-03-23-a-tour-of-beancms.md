+++
title = "A Tour of Bean CMS"
+++

# A Tour of Bean CMS

[Bean CMS](https://github.com/kevinfiol/beancms) is a minimalist content management system. I built it as a personal replacement for the great [rwtxt](https://github.com/schollz/rwtxt). The motivation to build Bean CMS was:

1. I wanted to self-host rwtxt, but had some changes I wanted to make to the core application.

2. I wanted an excuse to build something using [redbean.dev](https://redbean.dev/) and [fullmoon](https://github.com/pkulchenko/fullmoon) while demonstrating that Redbean and Lua are viable options for building web applications

As a result of using redbean, Bean CMS is deployed as a single >7MB file that runs natively on Windows/MacOS/Linux -- all without cross-compilation! Take a look at the [repo](https://github.com/kevinfiol/beancms) for installation instructions.

## Getting up and running

In short, download `beancms.com` from the [releases](https://github.com/kevinfiol/beancms/releases) page. On Linux/MacOS, `chmod +x beancms.com`. Then, on Windows/Linux/MacOS, simply run the file while using the current directory to store persisted data:

```bash
./beancms.com -D ./
``` 

Right away, you'll notice a `data` directory created next to your executable. This is where all persisted data for Bean CMS is stored. Bean CMS uses SQLite as supported by Redbean, which means to back up your site data, all you have to do is copy the `data` folder.

{{ img(src="https://github.com/user-attachments/assets/18ed9c08-6e1e-456b-89b4-4421aa34c2c4" alt="files screenshot") }}

Upon opening the site at `localhost:8080`, you'll see the welcome page. From here, new users can register, or existing users can log in.

{{ img(src="https://github.com/user-attachments/assets/a21b2e28-971c-40a1-9d60-8784160ab11f") alt="welcome page" }}

## User Page

Upon logging in, users are able to customize their profile pages by modifying their personal title, filling in an intro section, selecting from multiple free/open-source themes, or adding their own custom CSS that will apply to their profile page as well as their writings.

<video src="https://github.com/user-attachments/assets/193b7f3c-75a0-4ac4-9050-f8948b5b3ced" />