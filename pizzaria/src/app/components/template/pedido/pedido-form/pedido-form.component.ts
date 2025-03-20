import { Component, OnInit, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from "@angular/forms";
import { MatIconModule } from '@angular/material/icon';
import { MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatRadioModule } from '@angular/material/radio';
import { HttpClient } from '@angular/common/http';
import { PedidoService } from '../pedido.service';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';

@Component({
  selector: 'app-pedido-form',
  standalone: true,
  imports: [
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    FormsModule,
    CommonModule,
    MatIconModule,
    MatRadioModule
  ],
  templateUrl: './pedido-form.component.html',
  styleUrls: ['./pedido-form.component.css']
})
export class PedidoFormComponent implements OnInit {

  nome: string = '';
  numero: string = '';
  rua: string = '';
  bairro: string = '';
  complemento: string = '';
  pagamento: string = '';
  pedidoDetails: string = '';

  private apiUrl = 'https://rahxsun55i.execute-api.sa-east-1.amazonaws.com/stage-api/pedido';

  constructor(
    private pedidoService: PedidoService,
    private http: HttpClient,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) {}

  ngOnInit(): void {
    this.pedidoDetails = this.data.pedidoString;
  }

  concluirPedido(): void {
    const pedido = {
      nome: this.nome,
      bairro: this.bairro,
      rua: this.rua,
      numero: this.numero,
      complemento: this.complemento,
      pedido: this.pedidoDetails,
      pagamento: this.pagamento
    };

    console.log(pedido);



    this.http.post(this.apiUrl, pedido).subscribe(
      response => {
        console.log('Pedido enviado com sucesso:', response);
        alert('Pedido concluído com sucesso!');
      },
      error => {
        console.error('Erro ao enviar pedido:', error);
        alert('Erro ao enviar o pedido. Tente novamente.');
      }
    );
  }
}
