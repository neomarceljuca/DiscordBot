defmodule Testebot.Consumer do

    use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
        cond do
            msg.content == "!oi" -> Api.create_message(msg.channel_id, "Ola, meu consagrado")

            String.starts_with?(msg.content, "!boss ") -> eldenring_boss_query(msg)
            String.starts_with?(msg.content, "!boss") ->
            Api.create_message(msg.channel_id, "Use **!boss <Nome>**.")

            true -> :ignore
        end
    end

    def handle_event(_event) do
        :noop
    end

    def eldenring_boss_query(msg) do
        corpo = String.split(msg.content, " ", parts: 2)
        bossName = Enum.fetch!(corpo, 1)
        resp = HTTPoison.get!("https://eldenring.fanapis.com/api/bosses?name=#{bossName}")

        {:ok, map} = Poison.decode(resp.body)

        case map["success"] do
            true ->
                #obtendo chave de dicionario, dentro de lista obtida atraves de outra chave de dicionario.
                #Formato da API {"data":[{"name": "exemplo"}]}
                name = Enum.at(map["data"],0)["name"]
                description = Enum.at(map["data"],0)["description"]
                location = Enum.at(map["data"],0)["location"]
                image = Enum.at(map["data"],0)["image"]
                Api.create_message(msg.channel_id, "Name: #{name}
            Description: #{description}
            Location: #{location}
            #{image}")

            false ->
                Api.create_message(msg.channel_id, "Comando Invalido!")
        end
    end

end
