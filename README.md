# Testebot

**Discord BOT - Com Elixir/Nostrum**

Bot criado como trabalho da cadeira de programação funcional, pela Universidade de Fortaleza. Realiza diversas funções em um canal de texto no discord através da biblioteca Nostrum.

##Funcionalidades

1- !erboss nome: Elden Ring API - Obter informações sobre o jogo por consulta get na API. obtém informações de itens, armas, armaduras, mobs, chefes e talismãs.
2- !pokedex nome/numero: Exibe informações básicas sobre determinado pokemon por nome ou número, utilizando a PokeAPI
3- !weather cidade: Exibe relatório geral climático de determinada cidade, com informações complementares, utilizando a OpenWeather API
4- !preview link: Fornece resumo e previsao de informacoes de um link fornecido.
5- !translate: Traduz qualquer texto fornecido em ingles para portugues, atraves da google translate API
6- !generateqr link: gera qr code copiável para qualquer link fornecido.
7- !lifeadvice: Gera conselho aleatório sobre a vida chamado por Advice Slip
8- !startup: Gera uma definição de StartUp
9- !wolfram search: Acessa a API do Wolfram e realiza pesquisa do que for informado em *search*
10- !dadjoke: gera dad joke anonima

---------------------------------------------------


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `testebot` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:testebot, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/testebot>.

