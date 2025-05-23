namespace BoardGamesMarket.Models;

public class Jogo
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public string Estado { get; set; } = string.Empty;
    public decimal Preco { get; set; }
    public string? ImagemUrl { get; set; }
    public int UsuarioId { get; set; }
}
