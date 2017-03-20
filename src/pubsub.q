/ Author: David Strachan

////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// PUBLISH/SUBSCRIBE ////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: Support custom where clause in subscription

.require.loadLib[("dotz";"timer")];

.dotz.append[`.z.pc;{[h]
    if[h=0;:()]; // Do not delete local pubsub
    delete from`.pubsub.priv.subscribers where handle=h;
    delete from`.pubsub.priv.publishers where handle=h;
    }];

.timer.atEvery[`pubsub.reset;00:00:00;{
    // Issue reset from top-level publisher
    if[0=count .pubsub.priv.publishers;
      tabs:raze value flip key .pubsub.priv.tables;
      .pubsub.priv.reset[tabs]];
    }];

/////////////
// PRIVATE //
/////////////

.pubsub.priv.publisher:([table:`symbol$()]
  handle:`int$())

.pubsub.priv.subscribers:([table:`symbol$();handle:`int$()]
  callback:`symbol$())

.pubsub.priv.tables:([table:`symbol$()]
  position:`long$())

///
// Reset pubsub position for given tables
// @param tabs symbolList Table names
.pubsub.priv.reset:{[tabs]
  .log.info("Resetting pubsub position - tables:";tabs);
  update position:0 from`.pubsub.priv.tables where table in tabs;
  handle:exec distinct handle from .pubsub.priv.subscribers where table in tabs;
  @[;(`.pubsub.priv.reset:tabs);::]'[handles];
  }

///
// Publishes data to local callback function
// @param table symbol Table name
// @param data table Data to publish
// @param position long Published position
// @param callback symbol Callback function
.pubsub.priv.publish:{[table;data;position;callback]
  // Only publish new data
  if[position<.pubsub.priv.tables[table;`position];
    :()];

  upsert[`.pubsub.priv.tables;(table;position)];

  @[0;(callback;table;data;position);::];
  }

///
// Issue a manual query to catchup a new subscriber
// @param table symbol Table name
// @param start long Start index
// @param end long End index
.pubsub.priv.query:{[table;start;end]
  handle:.pubsub.priv.publishers[table;`handle];
  $[null handle;
    ?[table;enlist(within;`i;(enlist;start;end));0b;()];
    @[handle;(`.pubsub.priv.query;table;start;end);::]]}

///
// Catchup a new subscriber by chunking query into 100k rows
// @param table symbol Table name
// @param callback symbol Callback function
// @param startPos long Start index
// @param endPos long End index
.pubsub.priv.catchup:{[table;callback;startPos;endPos]
  .log.info("Running catchup - table:";table;"callback:";callback;"start position:";startPos;"end position:";endPos);

  handle:.pubsub.priv.publishers[table;`handle];
  if[null handle;
    handle:0i];

  chunk:100000;
  while[startPos<endPos;
    end:min(startPos+chunk-1;endPos-1);

    // Query for data from handle
    data:@[handle;(`.pubsub.priv.query;table;startPos;end);::];

    // publish data to subscriber
    @[neg .z.w;(callback;table;data;end+1);::];

    startPos+:chunk];
  }

///
// Registers new remote subscriber process for a given table
// @param table symbol Table name
// @param callback symbol Callback function used for publishing data
// @param position long Number of rows already received by subscriber
.pubsub.priv.subscribe:{[table;callback;position]
  .log.info("Incoming subscription from handle";.z.w;"- table:";table;"callback:";callback;"position:";position);

  upsert[`.pubsub.priv.subscribers;(table;.z.w;callback)];

  if[position<newPosition:0^.pubsub.priv.tables[table;`position];
    .log.info("New subscriber is behind published position - table:";table);
    .pubsub.priv.catchup[table;callback;position;newPosition]];
  newPosition}

///
// Delete subscriber identified by specified table and handle
// @param table symbol Table name
// @param handle int Handle to subscriber
.pubsub.priv.deleteSubscriber:{[table;handle]
  .log.info("Deleting subscriber - table:";table;"handle:";handle);

  ![`.pubsub.priv.subscribers;((=;`table;enlist table);(=;`handle;enlist handle));0b;`symbol$()];
  }

////////////
// PUBLIC //
////////////

///
// Publish data to remote subscribers
// @param table symbol Table name
// @param data table Data to publish
// @param position long Published position
.pubsub.publish:{[table;data;position]
  // Only publish new data
  if[position<.pubsub.priv.tables[table;`position];
    :()];

  //.log.info("Publishing";count data;"rows - table:";table;"position:";position);

  subscribers:?[`.pubsub.priv.subscribers;enlist(=;`table;enlist table);();`handle`callback!`handle`callback];

  // Publish data to all subscribers
  {[table;data;position;handle;callback]
    @[neg handle;(`.pubsub.priv.publish;table;data;position;callback);{
        // Delete subscriber if publish failed
        .pubsub.priv.deleteSubscriber[table;handle];
        }];
    }[table;data;position]'[subscribers`handle;subscribers`callback];

  upsert[`.pubsub.priv.tables;(table;position)];
  }

///
// Subscribe to remote data
// @param handle int Handle to publisher process
// @param table symbol Table name
// @param callback symbol Callback function
// @param position long Number of rows already received by subscriber
.pubsub.subscribe:{[handle;table;callback;position]
  .log.info("Issuing subscription to handle";handle;"- table:";table;"position:";position);

  res:not 0b~position:@[handle;(`.pubsub.priv.subscribe;table;callback;position);0b];

  if[res;
    upsert[`.pubsub.priv.publishers;(table;handle)];
    upsert[`.pubsub.priv.tables;(table;position)]];
  res}
