using Microsoft.AspNetCore.Mvc;
using BoardGamesMarket.Models;
using BoardGamesMarket.Data;
using Dapper;

namespace BoardGamesMarket.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly DbConnectionFactory _connectionFactory;

    public AuthController(DbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] Usuario usuario)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = @"INSERT INTO Usuarios (Nome, Email, SenhaHash) 
                    VALUES (@Nome, @Email, @SenhaHash)";

        await connection.ExecuteAsync(sql, usuario);
        return Ok();
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromQuery] string email, [FromQuery] string senha)
    {
        using var connection = _connectionFactory.CreateConnection();
        var usuario = await connection.QueryFirstOrDefaultAsync<Usuario>(
            "SELECT * FROM Usuarios WHERE Email = @Email AND SenhaHash = @Senha",
            new { Email = email, Senha = senha });

        return usuario is not null ? Ok(usuario) : Unauthorized();
    }
}
