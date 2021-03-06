#' Generalized Coco
#'
#' Implement blockwise coordinate descent algorithm or CoCoLasso algorithm
#'
#' @param Z Corrupted design matrix (with additive error or missing data)
#' @param y Response vector
#' @param n Number of samples of the design matrix
#' @param p Number of features of the matrix
#' @param p1 Number of uncorrupted predictors (if dealing with block descent)
#' @param p2 Number of corrupted predictors containing additive error (if dealing with block descent)
#' @param p3 Number of corrupted predictors containing missingness (if dealing with block descent)
#' @param center.Z If TRUE, centers Z matrix without taking into account NAs values, and then change NAs to 0 value (in the
#' missing data setting).
#' @param scale.Z If TRUE, divides Z columns by their standard deviation
#' @param center.y If TRUE, centers y
#' @param scale.y If TRUE, divides y by its standard deviation
#' @param lambda.factor Range of the lambda interval we are going to explore
#' @param step Number of values of lambda in the interval we are going to test
#' @param K Number of folds for the cross-validation
#' @param mu Penalty parameter for the ADMM algorithm
#' @param tau Standard deviation for the additive error matrix in the additive error setting (NULL in the missing data setting)
#' @param etol Tolerance parameter for the ADMM algorithm. This parameter has an impact on computing speed, since it controls
#' the number of iterations of the ADMM algorithm which can be quite slow when the number of features increases.
#' @param optTol Tolerance parameter for the convergence of the error in the pathwise coordinate descent. This parameter
#' has an impact on computing speed, since it controls when the algorithm stops after error convergence. It should be adapted
#' with regard of the error values. For centered and scaled matrix, a value of \code{optTop} at 1e-5 usually works fine.
#' @param earlyStopping_max Number of iterations allowed when the cross-validation error starts increasing. This parameter
#' has an impact on computing speed, since iterations corresponding to increasing error are usually quite slow.
#' @param penalty Type of penalty used : can be lasso penalty or SCAD penalty
#' @param mode ADMM or HM
#' 
#' @return list containing \itemize{
#' \item \code{lambda.opt} optimal value of lambda corresponding to minimum error
#' \item \code{lambda.sd} Value of lambda corresponding to error higher than minimum error by one standard deviation
#' \item \code{beta.opt} Value of beta corresponding to \code{lambda.opt}
#' \item \code{beta.sd} Value of beta corresponding to \code{lambda.sd}
#' \item \code{data_error} Dataframe containing errors and their standard deviation for each iteration of the algorithm
#' \item \code{data_beta} Dataframe containing the values of beta for each iteration of the algorithm
#' \item \code{earlyStopping} Integer containing the value of iteration when early stopping happens
#' \item \code{vnames} Names of the features
#' \item \code{mean.Z} Mean of Z matrix without the NAs values
#' \item \code{sd.Z} Standard deviation of Z matrix without the NAs values
#' \item \code{mean.y} Mean of y matrix
#' \item \code{sd.y} Standard deviation of y matrix
#' }
#' 
#' @details It is highly recommended to use center.Z = TRUE for the algorithm to work in the case of missing data. 
#' It is recommended to use center.Z = TRUE, scale.Z = TRUE, center.y = TRUE and scale.y = TRUE for both convergence
#' and interpretability reasons. The use of center.Z = TRUE in the additive error setting can be subject to discussion,
#' as it may introduce bias in the algorithm.
#' For computing speed reasons, if model is not converging or running slow, consider changing \code{mu}, decreasing
#' \code{etol} or \code{optTol} or decreasing \code{earlyStopping_max}
#' 
#' @seealso \url{https://arxiv.org/pdf/1510.07123.pdf}, \code{\link{blockwise_coordinate_descent}}, \code{\link{pathwise_coordinate_descent}}
#' 
#' @export
#' 

generalcoco <- function(Z, 
                 y,
                 n,
                 p,
                 p1=NULL,
                 p2=NULL,
                 p3=NULL, # both types of noise; removed noise parameter; removed block parameter since only BDCoCoLasso can handle this setting
                 center.Z = TRUE,
                 scale.Z = TRUE,
                 center.y = TRUE,
                 scale.y = TRUE,
                 lambda.factor=ifelse(dim(Z)[1] < dim(Z)[2],0.01,0.001),
                 step=100,
                 K=4,
                 mu=10,
                 tau = NULL,
                 etol= 1e-4,
                 optTol = 1e-5,
                 earlyStopping_max = 10,
                 penalty=c("lasso","SCAD"),
                 mode="ADMM"){
  
  this.call <- match.call()
  fit <- blockwise_coordinate_descent_general(Z=Z,
                                                     y=y,
                                                     n=n,
                                                     p=p,
                                                     p1=p1,
                                                     p2=p2,
                                                     p3=p3,
                                                     center.Z = center.Z,
                                                     scale.Z = scale.Z,
                                                     center.y = center.y,
                                                     scale.y = scale.y,
                                                     lambda.factor = lambda.factor,
                                                     step = step,
                                                     K = K,
                                                     mu = mu,
                                                     tau = tau,
                                                     etol = etol,
                                                     optTol = optTol,
                                                     earlyStopping_max = earlyStopping_max,
                                                     penalty=penalty,
                                              mode=mode)
  fit$call <- this.call
  class(fit) <- "coco"
  return(fit)
}
