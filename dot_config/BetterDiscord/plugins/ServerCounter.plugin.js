/**
 * @name ServerCounter
 * @author DevilBro
 * @authorId 278543574059057154
 * @version 1.0.8
 * @description Adds a Server Counter to the Server List
 * @invite Jx3TjNS
 * @donate https://www.paypal.me/MircoWittrien
 * @patreon https://www.patreon.com/MircoWittrien
 * @website https://mwittrien.github.io/
 * @source https://github.com/mwittrien/BetterDiscordAddons/tree/master/Plugins/ServerCounter/
 * @updateUrl https://mwittrien.github.io/BetterDiscordAddons/Plugins/ServerCounter/ServerCounter.plugin.js
 */

module.exports = (_ => {
	const changeLog = {
		
	};

	return !window.BDFDB_Global || (!window.BDFDB_Global.loaded && !window.BDFDB_Global.started) ? class {
		constructor (meta) {for (let key in meta) this[key] = meta[key];}
		getName () {return this.name;}
		getAuthor () {return this.author;}
		getVersion () {return this.version;}
		getDescription () {return `The Library Plugin needed for ${this.name} is missing. Open the Plugin Settings to download it. \n\n${this.description}`;}
		
		downloadLibrary () {
			BdApi.Net.fetch("https://mwittrien.github.io/BetterDiscordAddons/Library/0BDFDB.plugin.js").then(r => {
				if (!r || r.status != 200) throw new Error();
				else return r.text();
			}).then(b => {
				if (!b) throw new Error();
				else return require("fs").writeFile(require("path").join(BdApi.Plugins.folder, "0BDFDB.plugin.js"), b, _ => BdApi.showToast("Finished downloading BDFDB Library", {type: "success"}));
			}).catch(error => {
				BdApi.alert("Error", "Could not download BDFDB Library Plugin. Try again later or download it manually from GitHub: https://mwittrien.github.io/downloader/?library");
			});
		}
		
		load () {
			if (!window.BDFDB_Global || !Array.isArray(window.BDFDB_Global.pluginQueue)) window.BDFDB_Global = Object.assign({}, window.BDFDB_Global, {pluginQueue: []});
			if (!window.BDFDB_Global.downloadModal) {
				window.BDFDB_Global.downloadModal = true;
				BdApi.showConfirmationModal("Library Missing", `The Library Plugin needed for ${this.name} is missing. Please click "Download Now" to install it.`, {
					confirmText: "Download Now",
					cancelText: "Cancel",
					onCancel: _ => {delete window.BDFDB_Global.downloadModal;},
					onConfirm: _ => {
						delete window.BDFDB_Global.downloadModal;
						this.downloadLibrary();
					}
				});
			}
			if (!window.BDFDB_Global.pluginQueue.includes(this.name)) window.BDFDB_Global.pluginQueue.push(this.name);
		}
		start () {this.load();}
		stop () {}
		getSettingsPanel () {
			let template = document.createElement("template");
			template.innerHTML = `<div style="color: var(--header-primary); font-size: 16px; font-weight: 300; white-space: pre; line-height: 22px;">The Library Plugin needed for ${this.name} is missing.\nPlease click <a style="font-weight: 500;">Download Now</a> to install it.</div>`;
			template.content.firstElementChild.querySelector("a").addEventListener("click", this.downloadLibrary);
			return template.content.firstElementChild;
		}
	} : (([Plugin, BDFDB]) => {
		return class ServerCounter extends Plugin {
			onLoad () {
				this.modulePatches = {
					after: [
						"GuildsBar"
					]
				};
			}
			
			onStart () {
				BDFDB.DiscordUtils.rerenderAll();
			}
			
			onStop () {
				BDFDB.DiscordUtils.rerenderAll();
			}
		
			processGuildsBar (e) {
				const process = returnValue => {
					let [children, index] = BDFDB.ReactUtils.findParent(returnValue, {name: "UnreadDMs"});
					if (index > -1) children.splice(index + 1, 0, BDFDB.ReactUtils.createElement("div", {
						className: BDFDB.disCNS.guildouter + BDFDB.disCN._servercounterservercountwrap,
						children: BDFDB.ReactUtils.createElement("div", {
							className: BDFDB.disCNS.guildslabel + BDFDB.disCN._servercounterservercount,
							children: `${BDFDB.LanguageUtils.LanguageStrings.SERVERS} – ${BDFDB.LibraryStores.SortedGuildStore.getFlattenedGuildIds().length}`
						})
					}));
				};
				let themeWrapper = BDFDB.ReactUtils.findChild(e.returnvalue, {filter: n => n && n.props && typeof n.props.children == "function"});
				if (themeWrapper) {
					let childrenRender = themeWrapper.props.children;
					themeWrapper.props.children = BDFDB.TimeUtils.suppress((...args) => {
						let children = childrenRender(...args);
						process(children);
						return children;
					}, "Error in Children Render of Theme Wrapper!", this);
				}
				else process(e.returnvalue);
			}
		};
	})(window.BDFDB_Global.PluginUtils.buildPlugin(changeLog));
})();
