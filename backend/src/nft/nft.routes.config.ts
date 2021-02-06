import { CommonRoutesConfig } from '../common/common.routes.config';
import express from 'express';

export class NFTRoutes extends CommonRoutesConfig {
    constructor(app: express.Application) {
        super(app, 'NFTRoutes');
    }

    configureRoutes() {
        this.app.route(`/nft`)
            .get((req: express.Request, res: express.Response) => {
                res.status(200).send(`Get NFT metadata`);
            })
        this.app.route(`/nft/:tokenID`)
            .all((req: express.Request, res: express.Response, next: express.NextFunction) => {
                // this middleware function runs before any request to /nft/:tokenID
                // but it doesn't accomplish anything just yet---
                // it simply passes control to the next applicable function below using next()
                next();
            })
            .get((req: express.Request, res: express.Response) => {
                let metadata = {
                    "description": "DAppNode NFT",
                    "external_url": "https://dappnode.io",
                    "image": "https://gateway.pinata.cloud/ipfs/QmV6PZ2AiJGJK7PSf1HLcKpjb5oCHCKWU3TZHQwwb813L2",
                    "name": `Nodler ID ${req.params.tokenID}`,
                }

                res.status(200).send(metadata);
            })

        return this.app;
    }

}