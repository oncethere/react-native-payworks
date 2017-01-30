//
//  PayworksNative.m
//  ReactNativePayworks
//
//  Created by Peace Chen on 1/19/17.
//  Copyright © 2017 OnceThere. All rights reserved.
//

#import "ReactNativePayworks.h"

@implementation PayworksNative

@synthesize bridge = _bridge;

MPTransactionProcess *signatureProcess;

RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(transaction,
                 xactionParams:(NSDictionary *)xactionParams
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    MPTransactionProvider* transactionProvider =
    [MPMpos transactionProviderForMode:MPProviderModeTEST
                    merchantIdentifier:xactionParams[@"merchantIdentifier"]
                     merchantSecretKey:xactionParams[@"merchantSecretKey"] ];

    MPTransactionParameters *transactionParameters =
    [MPTransactionParameters chargeWithAmount:xactionParams[@"chargeWithAmount"]
                                     currency:[RCTConvert int:xactionParams[@"currency"]]
                                    optionals:^(id<MPTransactionParametersOptionals>  _Nonnull optionals)
                                    {
                                        optionals.subject = xactionParams[@"optionals"][@"subject"];
                                        optionals.customIdentifier = xactionParams[@"optionals"][@"customIdentifier"];
                                        optionals.applicationFee = xactionParams[@"optionals"][@"applicationFee"];
                                        // Specify up to 20 key-value pairs (See https://stripe.com/docs/api#metadata)
                                        optionals.metadata = xactionParams[@"optionals"][@"metadata"];
                                    }];

    MPAccessoryParameters *ap;
    if ([xactionParams[@"linkType"] isEqualToString:@"WiFi"]) {
      // When using the WiFi Miura M010, use the following parameters:
      ap = [MPAccessoryParameters tcpAccessoryParametersWithFamily:MPAccessoryFamilyMiuraMPI
                                                            remote:@"192.168.254.123"
                                                              port:38521
                                                         optionals:nil];
    } else {
      // When using the Bluetooth Miura Shuttle / M007 / M010, use the following parameters:
      ap = [MPAccessoryParameters externalAccessoryParametersWithFamily:MPAccessoryFamilyMiuraMPI
                                                              protocol:@"com.miura.shuttle"
                                                             optionals:nil];
    }

    // MPTransactionProcess *process =
    [transactionProvider startTransactionWithParameters:transactionParameters
                                    accessoryParameters:ap
                                             registered:^(MPTransactionProcess *process,
                                                          MPTransaction *transaction)
     {
        //  NSLog(@"registered MPTransactionProcess, transaction id: %@", transaction.identifier);
         [self.bridge.eventDispatcher sendAppEventWithName:@"PayworksTransactionEvent"
                                                      body:[self createTransactionDetailsObject:transaction details:nil]];
     }
                                        statusChanged:^(MPTransactionProcess *process,
                                                        MPTransaction *transaction,
                                                        MPTransactionProcessDetails *details)
     {
        //  NSLog(@"%@\n%@", details.information[0], details.information[1]);
         [self.bridge.eventDispatcher sendAppEventWithName:@"PayworksTransactionEvent"
                                                      body:[self createTransactionDetailsObject:transaction details:details]];
     }
                                       actionRequired:^(MPTransactionProcess *process,
                                                        MPTransaction *transaction,
                                                        MPTransactionAction action,
                                                        MPTransactionActionSupport *support)
     {
         switch (action) {
             case MPTransactionActionCustomerSignature: {
                // NSLog(@"show a UI that let's the customer provide his/her signature!");
                signatureProcess = process;
                [self.bridge.eventDispatcher sendAppEventWithName:@"PayworksTransactionEvent"
                                                             body:@{@"action": @"MPTransactionActionCustomerSignature"}];
                break;
             }
             case MPTransactionActionCustomerIdentification: {
                 // always return NO here
                 [process continueWithCustomerIdentityVerified:NO];
                 break;
             }
             case MPTransactionActionApplicationSelection: {
                 // This happens only for readers that don't support application selection on their screen
                 break;
             }
             default: {
                 break;
             }
         }
     }

    completed:^(MPTransactionProcess *process,
              MPTransaction *transaction,
              MPTransactionProcessDetails *details)
     {
        //  NSLog(@"Transaction ended, transaction status is %lu", (unsigned long) transaction.status);
        NSString* status;

         switch(transaction.status) {
            default:
            case MPTransactionStatusUnknown:
              // Unknown or not available
              status = @"MPTransactionStatusUnknown";
              break;
            case MPTransactionStatusInitialized:
              // Transaction is initialized and can be started
              status = @"MPTransactionStatusInitialized";
              break;
            case MPTransactionStatusPending:
              // Transaction result is still pending (e.g. not finished or waiting for async workflow)
              status = @"MPTransactionStatusPending";
              break;
            case MPTransactionStatusApproved:
              // Transaction was approved.
              // Ask the merchant, whether the shopper wants to have a receipt
              // and close the checkout UI
              status = @"MPTransactionStatusApproved";
              break;
            case MPTransactionStatusDeclined:
              // Transaction was declined
              status = @"MPTransactionStatusDeclined";
              break;
            case MPTransactionStatusAborted:
              // Transaction was aborted (by merchant or shopper)
              status = @"MPTransactionStatusAborted";
              break;
            case MPTransactionStatusError:
              // An error occured, see [MPTransaction.error] for more details
              status = @"MPTransactionStatusError";
              break;
            case MPTransactionStatusInconclusive:
              // The transaction ended in a state that is inconclusive and the SDK cannot derive
              // the outcome (e.g. due to no internet connection). This is a special case of failure.
              status = @"MPTransactionStatusInconclusive";
              break;
         }

         NSDictionary* transDet = [self createTransactionDetailsObject:transaction details:details];
         resolve(@{
           @"status": status,
           @"transaction": transDet[@"transaction"],
           @"details": transDet[@"details"]
         });
     }];
}

RCT_REMAP_METHOD(submitSignature,
                 signature:(UIImage *)signature
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  [signatureProcess continueWithCustomerSignature:signature verified:YES];

  // Add this instead, if you would like to collect the customer signature on the printed merchant receipt
  // [process continueWithCustomerSignatureOnReceipt];

  resolve( @{} );
}


// Create RCT-serializable transaction/details object
- (NSDictionary*) createTransactionDetailsObject: (MPTransaction*)transaction
                                         details: (MPTransactionProcessDetails*)details
{
  MPTransaction* _transaction;
  MPTransactionProcessDetails* _details;

  if (transaction == nil) {
    _transaction = [NSNull null];
  }
  else {
    MPCardDetails* _cardDetails;
    MPClearingDetails* _clearingDetails;

    if (transaction.cardDetails == nil) {
      _cardDetails = [NSNull null];
    }
    else {
      _cardDetails = @{
        @"cardHolderName": transaction.cardDetails.cardHolderName ?: [NSNull null],
        @"expiryMonth": [NSNumber numberWithUnsignedLong:transaction.cardDetails.expiryMonth],
        @"expiryYear": [NSNumber numberWithUnsignedLong:transaction.cardDetails.expiryYear],
        @"fingerprint": transaction.cardDetails.fingerprint ?: [NSNull null],
        @"maskedCardNumber": transaction.cardDetails.maskedCardNumber ?: [NSNull null],
        @"scheme": [NSNumber numberWithUnsignedLong:transaction.cardDetails.scheme]
      };
    }
    if (transaction.clearingDetails == nil) {
      _clearingDetails = [NSNull null];
    }
    else {
      _clearingDetails = @{
        @"institute": transaction.clearingDetails.institute ?: [NSNull null],
        @"transactionIdentifier": transaction.clearingDetails.transactionIdentifier ?: [NSNull null],
        @"originalTransactionIdentifier": transaction.clearingDetails.originalTransactionIdentifier ?: [NSNull null],
        @"completed": transaction.clearingDetails.completed ?
                          [NSDateFormatter localizedStringFromDate:transaction.clearingDetails.completed
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle]
                          : [NSNull null],
        @"authorizationCode": transaction.clearingDetails.authorizationCode ?: [NSNull null],
        @"merchantId": transaction.clearingDetails.merchantId ?: [NSNull null],
        @"terminalId": transaction.clearingDetails.terminalId ?: [NSNull null],
        @"statusText": transaction.clearingDetails.statusText ?: [NSNull null]
      };
    }

    _transaction = @{
      @"captured": [NSNumber numberWithBool:transaction.captured],
      @"amount": transaction.amount ?: [NSNull null],
      @"subject": transaction.subject ?: [NSNull null],
      @"type": [NSNumber numberWithUnsignedLong:transaction.type],
      @"status": [NSNumber numberWithUnsignedLong:transaction.status],
      @"state": [NSNumber numberWithUnsignedLong:transaction.state],
      @"error": transaction.error ?: [NSNull null],
      @"identifier": transaction.identifier ?: [NSNull null],
      @"customIdentifier": transaction.customIdentifier ?: [NSNull null],
      @"cardDetails": _cardDetails,
      @"clearingDetails": _clearingDetails
    };
  }

  if (details == nil) {
    _details = [NSNull null];
  }
  else {
    _details = @{
      @"state": [NSNumber numberWithInt:details.state],
      @"stateDetails": [NSNumber numberWithUnsignedLong:details.stateDetails],
      @"information": details.information ?: [NSNull null],
      @"error": details.error ? details.error.localizedDescription : [NSNull null],
    };
  }

  return @{
    @"transaction": _transaction,
    @"details": _details
  };
}

@end
