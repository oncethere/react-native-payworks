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
         NSLog(@"registered MPTransactionProcess, transaction id: %@", transaction.identifier);
     }
                                        statusChanged:^(MPTransactionProcess *process,
                                                        MPTransaction *transaction,
                                                        MPTransactionProcessDetails *details)
     {
         NSLog(@"%@\n%@", details.information[0], details.information[1]);
         [self.bridge.eventDispatcher sendAppEventWithName:@"PayworksTransactionEvent"
                                                      body:@{@"details": details.information}];
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
         NSLog(@"Transaction ended, transaction status is %lu", (unsigned long) transaction.status);

         NSString *status;
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
         resolve( @{
           @"status": status,
           @"transactionIdentifier": transaction.clearingDetails.transactionIdentifier,
           @"institute": transaction.clearingDetails.institute,
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

@end
