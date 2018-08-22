defmodule WhatsTheirFaceUserGenerator.CLI do
  require IEx

  def main(args) do
    args
    |> parse_args
    |> process
  end

  def parse_args(args) do
    parse =
      OptionParser.parse(args,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    case parse do
      {_, [class_name, amount], _} ->
        {class_name, amount}

      _ ->
        :help
    end
  end

  def process(:help) do
    IO.puts("""
    WhatsTheirFace User Generator
    — — — — — 
    usage: whatstheirface_user_generator <class name> <number of users>
    example: whatstheirface_user_generator 2A 20
    """)
  end

  def process({class_name, amount}) do
    fetch(amount)
    |> handle_json
    |> userdata
    |> Enum.map(&download(&1, class_name))
  end

  def fetch(amount) do
    HTTPoison.get("https://randomuser.me/api/?results=#{amount}&nat=de,gb,no,nl") 
  end

  def handle_json({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  def handle_json({_, %{status_code: _, body: _body}}) do
    IO.puts("Something went wrong. Please check your internet 
                connection")
  end

  def userdata(userdata), do: elem(userdata, 1)["results"]

  def download(user, class_name) do
    first_name = user["name"]["first"]
    last_name = user["name"]["last"]
    image_url = user["picture"]["large"]
    %HTTPoison.Response{body: body} = HTTPoison.get!(image_url)
    File.write("images/#{class_name} #{first_name} #{last_name}.jpg", body)
  end
end
