import { Component } from '@angular/core';
import {PackageService} from './_services/package.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {

  constructor(
    public packageServive: PackageService
  ) {}


  title = 'hello-world';

  doError() {
    throw new Error('This is an error');
  }
}
