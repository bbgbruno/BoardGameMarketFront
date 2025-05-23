using BoardGamesMarket.Data;
using Dapper;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", p =>
        p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

var connectionString = "Data Source=boardgames.db";
builder.Services.AddSingleton(new DbConnectionFactory(connectionString));


var app = builder.Build();

InicializarBanco(app.Services);


app.UseCors("AllowAll");

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapControllers();

app.Run();

void InicializarBanco(IServiceProvider services)
{
    using var scope = services.CreateScope();
    var connectionFactory = scope.ServiceProvider.GetRequiredService<DbConnectionFactory>();
    using var connection = connectionFactory.CreateConnection();

    var sql = @"
    CREATE TABLE IF NOT EXISTS Usuarios (
        Id TEXT PRIMARY KEY,
        Nome TEXT NOT NULL,
        Email TEXT NOT NULL UNIQUE,
        SenhaHash TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS Jogos (
        Id TEXT PRIMARY KEY,
        Titulo TEXT NOT NULL,
        Descricao TEXT,
        ImagemUrl TEXT,
        UsuarioId TEXT NOT NULL,
        FOREIGN KEY (UsuarioId) REFERENCES Usuarios(Id) ON DELETE CASCADE
    );
    ";

    connection.Execute(sql);
}

