/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * This is the main backend file that handle all the routes to assets modification
 * To avoid timeouts, long running tasks should be decoupled from HTTP request
 * processing
 *
 * Submit transactions can potentially be very long running, especially if the
 * transaction fails and needs to be retried one or more times
 *
 * To allow requests to respond quickly enough, this sample queues submit
 * requests for processing asynchronously and immediately returns 202 Accepted
 */

import express, { Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { Contract } from 'fabric-network';
import { getReasonPhrase, StatusCodes } from 'http-status-codes';
import { Queue } from 'bullmq';
import { AssetNotFoundError } from './errors';
import { evatuateTransaction } from './fabric';
import { addSubmitTransactionJob } from './jobs';
import { logger } from './logger';

const { ACCEPTED, BAD_REQUEST, INTERNAL_SERVER_ERROR, NOT_FOUND, OK } =
  StatusCodes;

export const assetsRouter = express.Router();

assetsRouter.get('/', async (req: Request, res: Response) => {
  logger.debug('Get all the list of doctors currently working in the hospital');
  try {
    const mspId = req.user as string;
    const contract = req.app.locals[mspId]?.assetContract as Contract;

    const data = await evatuateTransaction(contract, 'GetAllCurrentDoctors');
    let doctorList = [];
    if (data.length > 0) {
      doctorList = JSON.parse(data.toString());
    }

    return res.status(OK).json(doctorList);
  } catch (err) {
    logger.error({ err }, 'Error processing get all doctors request');
    return res.status(INTERNAL_SERVER_ERROR).json({
      status: getReasonPhrase(INTERNAL_SERVER_ERROR),
      timestamp: new Date().toISOString(),
    });
  }
});

assetsRouter.post(
  '/',
  body().isObject().withMessage('Body must contain data about Doctor'),
  body('doctorId', 'must be a string').notEmpty(),
  body('DoctorName', 'must be a string').notEmpty(),
  body('Specialization', 'must be a string').notEmpty(),
  body('Address', 'must be a string').notEmpty(),
  body('PhoneNumber', 'must be a string').notEmpty(),
  async (req: Request, res: Response) => {
    logger.debug(req.body, 'Request received for adding a new doctor');

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(BAD_REQUEST).json({
        status: getReasonPhrase(BAD_REQUEST),
        reason: 'VALIDATION_ERROR',
        message: 'Invalid request body',
        timestamp: new Date().toISOString(),
        errors: errors.array(),
      });
    }

    const mspId = req.user as string;
    const doctorId = req.body.doctorId;

    try {
      const submitQueue = req.app.locals.jobq as Queue;
      const jobId = await addSubmitTransactionJob(
        submitQueue,
        mspId,
        'AddDoctor',
        doctorId,
        req.body.DoctorName,
        req.body.Specialization,
        req.body.Address,
        req.body.PhoneNumber
      );

      return res.status(ACCEPTED).json({
        status: getReasonPhrase(ACCEPTED),
        jobId: jobId,
        timestamp: new Date().toISOString(),
      });
    } catch (err) {
      logger.error(
        { err },
        'Error processing create doctor request for doctor ID %s',
        doctorId
      );

      return res.status(INTERNAL_SERVER_ERROR).json({
        status: getReasonPhrase(INTERNAL_SERVER_ERROR),
        timestamp: new Date().toISOString(),
      });
    }
  }
);

assetsRouter.options('/:doctorId', async (req: Request, res: Response) => {
  const doctorId = req.params.doctorId;
  logger.debug('doctor options request received for doctor ID %s', doctorId);

  try {
    const mspId = req.user as string;
    const contract = req.app.locals[mspId]?.assetContract as Contract;

    const data = await evatuateTransaction(contract, 'DoctorExists', doctorId);
    const exists = data.toString() === 'true';

    if (exists) {
      return res
        .status(OK)
        .set({
          Allow: 'DELETE,GET,OPTIONS,PATCH,PUT',
        })
        .json({
          status: getReasonPhrase(OK),
          timestamp: new Date().toISOString(),
        });
    } else {
      return res.status(NOT_FOUND).json({
        status: getReasonPhrase(NOT_FOUND),
        timestamp: new Date().toISOString(),
      });
    }
  } catch (err) {
    logger.error(
      { err },
      'Error processing doctor options request for doctor ID %s',
      doctorId
    );
    return res.status(INTERNAL_SERVER_ERROR).json({
      status: getReasonPhrase(INTERNAL_SERVER_ERROR),
      timestamp: new Date().toISOString(),
    });
  }
});

// assetsRouter.get('/:doctorId', async (req: Request, res: Response) => {
//   const doctorId = req.params.doctorId;
//   logger.debug('Read doctor request received for doctor ID %s', doctorId);

//   try {
//     const mspId = req.user as string;
//     const contract = req.app.locals[mspId]?.assetContract as Contract;

//     const data = await evatuateTransaction(contract, 'Readdoctor', doctorId);
//     const doctor = JSON.parse(data.toString());

//     const data2 = await evatuateTransaction(contract, 'ReaddoctorHistory', doctorId);
//     const doctorHistory = JSON.parse(data2.toString());

//     return res.status(OK).json({ doctor, doctorHistory });
//   } catch (err) {
//     logger.error(
//       { err },
//       'Error processing read doctor request for doctor ID %s',
//       doctorId
//     );

//     if (err instanceof AssetNotFoundError) {
//       return res.status(NOT_FOUND).json({
//         status: getReasonPhrase(NOT_FOUND),
//         timestamp: new Date().toISOString(),
//       });
//     }

//     return res.status(INTERNAL_SERVER_ERROR).json({
//       status: getReasonPhrase(INTERNAL_SERVER_ERROR),
//       timestamp: new Date().toISOString(),
//     });
//   }
// });

// assetsRouter.put(
//   '/:doctorId',
//   body().isObject().withMessage('body must contain an doctor object'),
//   body('ID', 'must be a string').notEmpty(),
//   body('Name', 'must be a string').notEmpty(),
//   body('DateOfBirth', 'must be a valid date string').notEmpty(),
//   body('Gender', 'must be a number (0: Female, 1: Male)').isNumeric(),
//   body('Address', 'must be a string').notEmpty(),
//   body('PhoneNumber', 'must be a string').notEmpty(),
//   body('Insurance', 'must be a string').notEmpty(),
//   body('Medication', 'must be an array of string').isArray(),
//   body('Diagnosis', 'must be an array of string').isArray(),
//   async (req: Request, res: Response) => {
//     logger.debug(req.body, 'Update doctor request received');

//     const errors = validationResult(req);
//     if (!errors.isEmpty()) {
//       return res.status(BAD_REQUEST).json({
//         status: getReasonPhrase(BAD_REQUEST),
//         reason: 'VALIDATION_ERROR',
//         message: 'Invalid request body',
//         timestamp: new Date().toISOString(),
//         errors: errors.array(),
//       });
//     }

//     if (req.params.doctorId != req.body.ID) {
//       return res.status(BAD_REQUEST).json({
//         status: getReasonPhrase(BAD_REQUEST),
//         reason: 'ASSET_ID_MISMATCH',
//         message: 'Asset IDs must match',
//         timestamp: new Date().toISOString(),
//       });
//     }

//     const mspId = req.user as string;
//     const doctorId = req.params.doctorId;

//     try {
//       const submitQueue = req.app.locals.jobq as Queue;
//       const jobId = await addSubmitTransactionJob(
//         submitQueue,
//         mspId,
//         'Updatedoctor',
//         doctorId,
//         req.body.Name,
//         req.body.DateOfBirth,
//         req.body.Gender,
//         req.body.Address,
//         req.body.PhoneNumber,
//         req.body.Insurance,
//         req.body.Medication,
//         req.body.Diagnosis
//       );

//       return res.status(ACCEPTED).json({
//         status: getReasonPhrase(ACCEPTED),
//         jobId: jobId,
//         timestamp: new Date().toISOString(),
//       });
//     } catch (err) {
//       logger.error(
//         { err },
//         'Error processing update doctor request for doctor ID %s',
//         doctorId
//       );

//       return res.status(INTERNAL_SERVER_ERROR).json({
//         status: getReasonPhrase(INTERNAL_SERVER_ERROR),
//         timestamp: new Date().toISOString(),
//       });
//     }
//   }
// );

assetsRouter.delete('/:doctorId', async (req: Request, res: Response) => {
  logger.debug(req.body, 'Delete Doctor request received');

  const mspId = req.user as string;
  const doctorId = req.params.doctorId;

  try {
    const submitQueue = req.app.locals.jobq as Queue;
    const jobId = await addSubmitTransactionJob(
      submitQueue,
      mspId,
      'DeleteDoctor',
      doctorId
    );

    return res.status(ACCEPTED).json({
      status: getReasonPhrase(ACCEPTED),
      jobId: jobId,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    logger.error(
      { err },
      'Error processing delete doctor request for doctor ID %s',
      doctorId
    );

    return res.status(INTERNAL_SERVER_ERROR).json({
      status: getReasonPhrase(INTERNAL_SERVER_ERROR),
      timestamp: new Date().toISOString(),
    });
  }
});
