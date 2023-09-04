# Changelog

Tout les changements notable de ce projet seront documenté dans ce fichier

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et le projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

### Changements

- Mise à jour du système openWRT vers la version 19.07.10.
- Mise à jour du kernel linux vers 4.14.276 patché pour inclure MPTCP v0.94.
- Remplacement du package swconfig en python2 de l'OTB v2B par une implémentation en C.
- Utilisation des packages jq et dnsmasq officiels à la place de la version présente dans les feeds overthebox
- Diverses améliorations sur le scripts de build et l'organisation des fichiers utilisés pour générer la configuration de l'image openWRT.

### Suppressions

- Suppression des packages depreciés yara, svfs, otb-full et otb de l'image.
- Suppression des configurations pour les architectures non supporté : mipsel32 et neoplus2

### Corrections

- Résolution d'un bug sur OTB v2B où une clé USB LTE n'est pas automatiquement détectée au boot
- Le partage de connexion avec un iPhone sous iOS14 ou supérieur est de nouveau fonctionnel

## [v0.6.35] - 2023-04-18

### Ajouts

- Ajout du package otb-graph, à terme ce package va remplacer le package graph. Il est utilisé pour remonter les informations nécessaires à la réalisation des graphiques des débits et d'utilisation des ressources systèmes présents sur l'espace client.
- Ajout de l'action otb-action-qos qui permet de déterminer et d'activer automatiquement le "traffic control" sur les interfaces WAN.
- Ajout du package Nano, installé par défaut dans l'image en plus de vim.
- Ajout des packages optionnels : prometheus-node-exporter-lua-x, ces packages ne sont pas disponibles directement dans l'image mais peuvent être installés grâce à l'utilitaire opkg.

### Changements

- Mise à jour des packages officiels d'openwrt 18.06
- Déplacement du code fonctionnel otb-action-speedtest vers lib/overthebox. Ce changement n'a pas d'incidence sur le fonctionnement de l'action otb-action-speedtest
- Utilisation des modules git pour générer le build de l'image

### Corrections

- Résolution d'un bug où le parser json jq génère beaucoup de log lorsque les interfaces réseaux ne sont pas disponibles
- Résolution d'un bug sur l'interface luci qui affichait 0.0.0.0 au lieu de l'adresse IP publique du service OverTheBox
- Résolution d'un bug de l'action otb-action-sysupgrade qui ne récupère pas la bonne URL d'image lorsque aucune URL n'est fournie en argument.

## [v0.6.33] - 2021-09-24

### Changements

- Mise à jour de l'URL du provisionning OVHcloud

### Corrections

- Pas d'affichage de l'interface pour changer le DHCP si l'appareil a plus d'un port ethernet
- Mise à jour de la version de shadowsocks-libev pour résoudre un soucis de fuite mémoire
- Correction d'otb-action-speedtes qui affiché parfois 0
- Autres corrections mineures

## [>= v0.6.32] - 2021-02-06

Les versions inférieures à v0.6.33 ne sont plus supporté suite à un changement sur notre infrastructure de provisioning
