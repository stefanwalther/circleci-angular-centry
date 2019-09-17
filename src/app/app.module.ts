import { BrowserModule } from '@angular/platform-browser';
import { APP_INITIALIZER, ErrorHandler, NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import {SentryErrorHandler} from './_lib/sentry-error-handler';
import {SettingsHttpService} from './_services/settings.http.service';
import {HttpClientModule} from '@angular/common/http';

export function app_Init(settingsHttpService: SettingsHttpService) {
  return () => settingsHttpService.initializeApp();
}

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule
  ],
  providers: [
    {provide: APP_INITIALIZER, useFactory: app_Init, deps: [SettingsHttpService], multi: true},
    {provide: ErrorHandler, useClass: SentryErrorHandler}
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
