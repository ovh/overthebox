# Changelog

Tout les changements notable de ce projet seront documenté dans ce fichier

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et le projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# v1.0

## [v1.0.0] - 2024-06-05
### Ajouts
- openwrt: Mise à jour vers la version 23.05.2
- openwrt: Mise à jour du kernel linux en version 5.15.137 avec support de MPTCPv1
- openwrt: Mise à jour des paquets pour supporter [nftables](https://openwrt.org/docs/guide-user/firewall/misc/nftables)
- mptcp: Migration vers MPTCPv1, implementation officielle de [MPTCP](https://www.mptcp.dev/) dans le kernel linux
- glorytun: Mise à jour vers v0.3.4, une version plannifiée pour la version v0.7 qui n'a jamais été déployée, ceci enlève le tunnel glorytun TCP. L'ensemble du traffic transit désormais par un unique tunnel UDP
- shadowsocks-libev: Mise à jour pour supporter MPTCPv1
- qos: Migration vers cake, cela permet une meilleur gestion de la QoS sans intervention utilisateur
- uqmi: Amélioration de l'intégration d'uqmi pour le support des modules LTE en NVME

### Suppressions
- Suppression de glorytun-tcp, remplacé par un unique tunnel UDP
- Suppression d'iptables, remplacé par netfilter
- Suppression de MPTCPv0, le kernel linux n'inclus plus de patch pour supporter cette implémentation

# v0.9

**Les appareils avec un port ethernet unique ne sont plus supportés**

## [v0.9.4] - 2024-06-05
### Corrections
- luci: La section enregistrement ne se bloque plus si un service n'a pas d'appareil associé

## [v0.9.3] - 2024-02-22
### Ajouts
- luci: Ajout de la traduction française de la section overthebox
- arp-scan: Ajout en temps que paquet optionnel

### Corrections
- luci: Les graphiques pour l'interface wwan0 sont affichés correctement
- luci: La section enregistrement attends correctement que le service soit activé

## [v0.9.2] - 2024-01-16
### Ajouts
- luci: Activation de la traduction en Français de l'interface, la traduction n'est pas encore finalisée sur les pages de l'onglet OverTheBox
- luci: Ajout d'une barre qui indique la progression dans les différentes étapes de l'enregistrement
- luci: Un label peut être ajouté à une interface dans la section reséau
- luci: Ajout des graphiques de trafic WAN dans la section graphiques temps réel
- luci: Ajout des graphiques de trafic LAN dans la section graphiques temps réel
- luci: Ajout du bouton pour réinitialiser la configuration du switch
- openwrt: Ajout de qmi-utils et luci-proto-qmi utilisés pour le support des cartes LTE en nvme

### Modifications
- luci: Si un label a été configuré sur l'interface c'est ce dernier qui sera montré plutôt que le nom de l'interface sur la page Aperçu
- luci: Les sections Service et WAN ont été remplacées par une carte Réseau similaire à ce qui était présent sur la version v0.8.1
- luci: Le modèle du matériel est raccourci pour les modèles connus : OTB v2c, OTB v2b, Qemu
- luci: Les labels d'interfaces sont préservés lors de l'édition de la configuration du switch de l'OTB v2b
- luci: Certain appels RPC de Luci ont été factorisés dans un fichier dédié, il peut être possible qu'un rafraîchissement du cache du navigateur soit nécessaire

### Corrections
- luci: Les VLAN eth0.3 et eth0.4 sont désormais réservés au port 13 et 14, ceci pour éviter des soucis lors de l’édition de la configuration du switch
- luci: Les logs Kernel sont affichés correctement
- luci: La redirection en HTTPS est correctement activée
- luci: Les interfaces contenant un "-" n'impactent plus l'affichage de la page Aperçu
- openwrt: Le site overthebox.ovh redirige correctement vers l'interface de l'otb
- otb-remote: Le nom d'utilisateur et le mot de passe sont correctement configurés sur LUCI pour l'accès à distance en HTTPS

## [v0.9.1] - 2023-11-14
### Ajouts
- luci-app-sqm: Un nouvel outil pour gérer la QoS, surtout utile pour des liens sujets à de fortes variations de latences.
- luci-app-statistics: Permet d'obtenir des statistiques plus détaillées sur le système de l'otb
- collectd: Ajout d'une sélection de packages optionnels pour étendre les statistiques affichées par luci-app-statistics

### Modifications
- openwrt: Mise à jour de LUCI vers la version native d'openWRT 21.02
- openwrt: L'interface web redirige automatiquement vers le https, les navigateurs modernes brident fortement JavaScript en http.
- luci: Refonte complète des pages du menu "OverTheBox" de l'interface web

### Corrections
- En cas de dépassement mémoire l'overthebox plante. Avant ce fix lors d'un dépassement mémoire les processus étaient arrêtés aléatoirement ce qui ne permettait pas de détecter le souci immédiatement.
- Résolution d'un bug sur les leds de l'OTB v2c introduit en version v0.9.0

## [v0.9.0] - 2023-05-17
### Ajouts
- openwrt: Mise à jour en 21.02.5
- openwrt: Mise à jour du noyau linux en 5.4.217 patché avec mptcp v0.96
- openwrt: Mise à jour des packages pour le support de Distributed Switch Architecture [DSA](https://openwrt.org/docs/guide-user/network/dsa/dsa-mini-tutorial)
- dnsmasq: Utilise désormais par défaut les DNS d'OVHcloud
- iperf3: Est désormais une dépendance du package overthebox
- otb-diagnostics: Mise à jour avec les améliorations développées pour la version v0.7 (jamais mise en production)
- otb-tracker: Mise à jour avec les améliorations développées pour la version v0.6.34 (jamais mise en production)
- otb-remote : Migration des clés SSH utilisées par l'OTB de RSA vers ed25519. Ces clés sont utilisées pour monter un accès à distance entre le serveur d'accès distant et l'OTB. Elles améliorent la sécurité mais n'ont pas d'impact sur votre utilisation de l'outil d'accès à distance. L'outil à distance ne supporte toujours pas pour le moment les clés au format ed25519

### Suppressions
- Suppression des packages dépréciés : graph et cherrytrail-gpio-powerbutton
- libcap n'est plus inclus explicitement, ceci était pour résoudre un bug sur la v0.8

### Corrections
- Résolution d'un bug sur IP2ASN qui ne remplissait pas correctement le champ WHOIS d'une interface WAN
- Fork d'iperf3 en version v3.7.1, le package officiel présentant des problèmes de compilation
- Le fichier de configuration udhcpc.user est directement importé depuis le dossier /root du repo overthebox pour éviter des conflits avec le package officiel

# v0.8
## [v0.8.1] - 2023-11-21
### Ajouts
- Ajout du support python3

### Suppressions
- Suppression du package déprecié graph

### Corrections
- Correction d'un soucis sur opkg à cause de l'absence d'IPv6

## [v0.8.0] - 2023-04-18
### Ajouts
- Ajout du package otb-v2c qui contient certaines customisations spécifiques à cette plateforme

### Modifications
- Mise à jour du système openWRT vers la version 19.07.10
- Mise à jour du kernel linux vers 4.14.276 patché pour inclure MPTCP v0.94
- Remplacement du package swconfig en python2 de l'OTB v2B par une implémentation en C
- Utilisation des packages jq et dnsmasq officiels à la place de la version présente dans les feeds overthebox
- Diverses améliorations sur le scripts de build et l'organisation des fichiers utilisés pour générer la configuration de l'image openWRT

### Suppressions
- Suppression des packages depreciés yara, svfs, otb-full et otb de l'image
- Suppression des configurations pour les architectures non supporté : mipsel32 et neoplus2

### Corrections
- Résolution d'un bug sur OTB v2B où une clé USB LTE n'est pas automatiquement détectée au boot
- Le partage de connexion avec un iPhone sous iOS14 ou supérieur est de nouveau fonctionnel

# v0.6
## [v0.6.35] - 2023-04-18
### Ajouts
- Ajout du package otb-graph, à terme ce package va remplacer le package graph. Il est utilisé pour remonter les informations nécessaires à la réalisation des graphiques des débits et d'utilisation des ressources systèmes présents sur l'espace client
- Ajout de l'action otb-action-qos qui permet de déterminer et d'activer automatiquement le "traffic control" sur les interfaces WAN
- Ajout du package Nano, installé par défaut dans l'image en plus de vim
- Ajout des packages optionnels : prometheus-node-exporter-lua-x, ces packages ne sont pas disponibles directement dans l'image mais peuvent être installés grâce à l'utilitaire opkg

### Modifications
- Mise à jour des packages officiels d'openwrt 18.06
- Déplacement du code fonctionnel otb-action-speedtest vers lib/overthebox. Ce changement n'a pas d'incidence sur le fonctionnement de l'action otb-action-speedtest
- Utilisation des modules git pour générer le build de l'image

### Corrections
- Résolution d'un bug où le parser json jq génère beaucoup de log lorsque les interfaces réseaux ne sont pas disponibles
- Résolution d'un bug sur l'interface luci qui affichait 0.0.0.0 au lieu de l'adresse IP publique du service OverTheBox
- Résolution d'un bug de l'action otb-action-sysupgrade qui ne récupère pas la bonne URL d'image lorsque aucune URL n'est fournie en argument

## [v0.6.33] - 2021-09-24
### Modifications
- Mise à jour de l'URL du provisionning OVHcloud

### Corrections
- Pas d'affichage de l'interface pour changer le DHCP si l'appareil a plus d'un port ethernet
- Mise à jour de la version de shadowsocks-libev pour résoudre un soucis de fuite mémoire
- Correction d'otb-action-speedtes qui affiché parfois 0
- Autres corrections mineures

## [>= v0.6.32] - 2021-02-06
Les versions inférieures à v0.6.33 ne sont plus supporté suite à un changement sur notre infrastructure de provisioning
