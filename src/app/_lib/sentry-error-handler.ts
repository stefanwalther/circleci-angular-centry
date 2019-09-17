import {ErrorHandler, Injectable} from '@angular/core';

import * as Sentry from '@sentry/browser';

// Lib
import * as _ from 'lodash';
import {PackageService} from '../_services/package.service';
import {SettingsService} from '../_services/settings.service';


@Injectable()
export class SentryErrorHandler implements ErrorHandler {
  constructor(
    private packageService: PackageService,
    private settingsService: SettingsService
  ) {
  }

  handleError(error) {
    console.log('OK; handle the error');
    console.log('settings', this.settingsService.settings);

    if (this.settingsService.settings.sentryDsn) {

      const pkg = this.packageService.getSync();

      Sentry.init({
        dsn: this.settingsService.settings.sentryDsn,
        environment: this.settingsService.settings.environment,
        release: `${pkg.name}@${pkg.version}`
      });


      // if (this.authenticationService.currentUser) {
      //   Sentry.configureScope(scope => {
      //     scope.setUser({
      //       id: _.get(this.authenticationService.currentUser, '_id'),
      //       username: _.get(this.authenticationService.currentUser, 'local.username'),
      //       email: _.get(this.authenticationService.currentUser, 'local.email'),
      //       // tslint:disable-next-line:max-line-length
      //       name: _.get(this.authenticationService.currentUser, 'firstname') + ' ' + _.get(this.authenticationService.currentUser, 'lastname')
      //     });
      //   });
      // }

      console.log('sentry-error-handling:', error);
      const eventId = Sentry.captureException(error.originalError || error);
      // Sentry.showReportDialog({ eventId });

    }
  }
}
