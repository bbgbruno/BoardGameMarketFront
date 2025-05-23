using Microsoft.AspNetCore.Mvc;
using BoardGamesMarket.Models;
using BoardGamesMarket.Data;
using Dapper;

namespace BoardGamesMarket.Controllers;

[ApiController]
[Route("api/[controller]")]
public class JogosController : ControllerBase
{
    private readonly DbConnectionFactory _connectionFactory;

    public JogosController(DbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? titulo)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "SELECT * FROM Jogos";
        if (!string.IsNullOrEmpty(titulo))
            sql += " WHERE Titulo LIKE @Titulo";

        var jogos = await connection.QueryAsync<Jogo>(sql, new { Titulo = $"%{titulo}%" });
        return Ok(jogos);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        var jogo = await connection.QueryFirstOrDefaultAsync<Jogo>(
            "SELECT * FROM Jogos WHERE Id = @Id", new { Id = id });

        return jogo is not null ? Ok(jogo) : NotFound();
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Jogo jogo)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = @"INSERT INTO Jogos (Titulo, Descricao, Estado, Preco, ImagemUrl, UsuarioId)
                    VALUES (@Titulo, @Descricao, @Estado, @Preco, @ImagemUrl, @UsuarioId)";

        await connection.ExecuteAsync(sql, jogo);
        return Ok();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.ExecuteAsync("DELETE FROM Jogos WHERE Id = @Id", new { Id = id });
        return Ok();
    }
}
