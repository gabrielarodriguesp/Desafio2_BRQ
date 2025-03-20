import { Component, OnInit } from '@angular/core';
import { MatTabsModule } from '@angular/material/tabs';


@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [MatTabsModule],
  templateUrl: './footer.component.html',
  styleUrls: ['./footer.component.css']
})
export class FooterComponent implements OnInit {

  constructor() { }

  ngOnInit(): void {
  }

}
