import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { Produto } from './produtos.model';

@Injectable({
  providedIn: 'root'
})
export class ProdutosService {

  private readonly API = 'https://gabrielarprado-cardapio-pizzaria.s3.sa-east-1.amazonaws.com/db.json';

  constructor(private http: HttpClient) { }

  public getProdutos(): Observable<Produto>{
    return this.http.get<Produto>(this.API);
  }
}
