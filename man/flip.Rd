\name{flip}
\alias{flip}
\alias{flip.statTest}
\alias{orthoZ}

%- Also NEED an '\alias' for EACH other topic documented here.
\title{
The main function for univariate and multivariate testing under a permutation (and rotation) framework + some utilities.
}
\description{
\code{flip} is the main function for permutation (or rotation) test.

It allows for multivariate one sample, C>=2 samples and any regression tests. Also the use of covariates (to be fitted in the model but) not under test is allowed.
}
\usage{
flip(Y, X=NULL, Z=NULL, data=NULL, tail = 0, perms = 1000, statTest=NULL, 
     Strata=NULL, flipReturn, testType=NULL, ...)

flip.statTest
#    c("t", "F", "ANOVA",
#  "Wilcoxon","Kruskal-Wallis", "kruskal", "rank", "Mann-Whitney",
#	"chisq","chisq.separated", "Fisher",
#  "McNemar", "Sign","sum","coeff","NA")

orthoZ(Y, X=NULL, Z=NULL, data=NULL,returnGamma=FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
    \item{Y}{The response vector of the regression model. May be
      supplied as a vector or as a \code{\link[stats:formula]{formula}}
      object. In the latter case, the right hand side of \code{Y}
      is passed on to \code{alternative} if that argument is missing, or
      otherwise to \code{null}.}

    \item{X}{The part of the design matrix corresponding to
      the alternative hypothesis. The covariates of the null model do
      not have to be supplied again here. May be given as a half
      \code{\link[stats:formula]{formula}} object (e.g. \code{~a+b}). In
      that case the intercept is always suppressed.}
    \item{Z}{The part of the design matrix corresponding to the null hypothesis. May be given as a design matrix or as a half \code{\link[stats:formula]{formula}} object (e.g. \code{~a+b}). The default for \code{Z} is \code{~1}, i.e. only an intercept. This intercept may be suppressed, if desired, with \code{Z = ~0}.}    
	\item{data}{Only used when \code{Y}, \code{X}, or \code{Z} is given in formula form. An optional data frame, list or environment containing the variables used in the formula. If the variables in a formula are not found in \code{data}, the variables are taken from environment(formula), typically the environment from which \code{gt} is called.}
  \item{tail}{Vector of values -1, 0 or 1 indicating the tail to be used in the test for each column of \code{Y}. \code{tail=1} (-1) means that greater (smaller) values bring more evidence to the alternative hypothesis. \code{tail=0} indicates a two sided alternative. If the length of \code{tail} is smaller than number of columns of \code{Y}, the values are recycled.}
\item{perms}{The number of permutations to use. The default is \code{perms = 1000}. Alternatively it can be a matrix (i.e. the permutation space) or a list with elements \code{number} and \code{seed}.}
\item{Strata}{A vector, which unique values identifies strata. This option is used only with \code{testType="permutation"};
parameter \code{Z} is not considered in this case. 
 Also note that when only two levels with one observation per each level are present in each stratum, the problem becomes a paired two-samples problem and hence simplified to a one-sample test.
}
\item{statTest}{
Choose from \code{flip.statTest}. See also Details section.
}
\item{flipReturn}{list of objects indicating what will be included in the output.

 e.g. \code{list(permP=TRUE,permT=TRUE,data=TRUE)}.}
 
\item{testType}{by default \code{testType="permutation"}. In alternative you can choose \code{"rotation"}
resampling is performed through random linear combinations (i.e. a rotation test is performed). This option is useful when only few permutations are available, that is, minimum reachable significance is hight.
The old syntax \code{rotationTest=TRUE} is maintained for compatibility  but is deprecated, use \code{testType="rotation"} instead.
}

\item{returnGamma}{logical. Should be the eigenvectors of the anti-projection matrix of \code{Z} (i.e. I- Z(Z'Z)^-1 Z') returned?}

\item{\dots}{Further parameters. The followings are still valid but deprecated:
 
\code{permT.return = TRUE, permP.return = FALSE}, 

\code{permSpace.return = FALSE, permY.return = FALSE}. Use \code{flipReturn} instead. 

\code{dummyfy} a named list of logical values (eg. \code{list(X=TRUE,Y=TRUE)})

\code{rotationTest= TRUE}. Deprecated, use \code{testType='rotation'} instead. 

}

}
\details{

\code{statTest="t"} is the t statistic derived from the correlation among the Xs and the Ys (i.e. a linear model for each couples of Xs and Ys). This is different
from the fit of a multiple (multivariate) linear models, since the correlation does not consider the other covariates).  The test \code{t} is valid only under the assumption that each variable in X is independent of each variable in Y. To get adequate test while adjusting for covariates, use \code{Z} (see example below)
The test statistic \code{"sum"} is the sum  of values (or frequencies) of the given sample 
centered on the expected (i.e. computed on the overall sample).
\code{"coeff"} is the statistic based on the estimated coefficient of lm.
It produce a test for every possible combination of (columns of) \code{X} and \code{Y} (p-values can be combined using \code{npc}).

\code{"ANOVA"} is synonyms of \code{"F"}. Only valid for dependence tests (i.e. non constant \code{X}). 
\code{"Mann-Whitney"} is synonyms of \code{"Wilcoxon"}. 
\code{"rank"} choose among \code{"Wilcoxon"} and \code{"Kruskal-Wallis"} depending if the samples are two or more (respectively).

The \code{"Wilcoxon"} statistic is based on the 'sum of ranks of second sample minus n1*(n+1)/2' instead of
'sum of ranks of smallest sample minus nSmallest*(n+1)/2'. Therefore the statistic is centered on 0 and allow for two sided alternatives.
Despite the p-value are ok, it requires the \code{X} to be a two-levels factor in order to compute the right test statistic.
When the \code{X} is not a two-levels factor, it measures the codeviance among \code{X} and ranks of \code{Y}.

For paired samples (see also the argument \code{Strata} and the example below) the Signed Rank test is performed.
To perform the Sign Test use option \code{Sign} (i.e. same as Signed Rank but without using magnitude of ranks).


The \code{"Fisher"} test is allowed only with dichotomous \code{Y}s. The reported statistic is the bottom-right cell of the 2 by 2 frequencies table.
The \code{"chisq.separated"} test perform cell-wise chi squared (see also Finos and Salmaso (2004) Communications in Statistics - Theory and methods).


The \code{"McNemar"} test is based on the signs of the differences, hence it can be used also with ordinal or continuous responses. Only valid for symmetry tests (i.e. \code{X} is constant or \code{NULL}). 
The reported statistic for \code{"McNemar"} test is the signed squared root of the McNemar statistic. Hence it allows for tailed alternatives.


For ordered \code{X}, a stochastic ordering test can be performed using \code{"t","Wilcoxon","sum"} and then combining the separated test using \code{npc}.

When \code{statTest} is a \code{function}, the first argument must be \code{Y}. This same function is ran to observed data \code{Y} and to a number of permuted rows of \code{Y}. The returned value must be a vector of test statistics. Please note that argument \code{tail} must be defined accordingly.
The default way the rows of \code{Y} are rearranged is through permutation (without strata). More complex permutation strategies can be defined through proper definition of argument \code{perm} (see also \code{\link{permutationSpace}}).
}


\value{An object of class \code{flip.object}. 
Several operations and plots can be made from this object. See also \code{\link{flip.object-class}}.}
\author{
livio finos (livioATstatDOTunipdDOTit)
}

\references{
For the general framework of univariate and multivariate permutation tests see: 
Pesarin, F. (2001) Multivariate Permutation Tests with Applications in Biostatistics. Wiley, New York.

for Rotation tests see: 
Langsrud, O. (2005) Rotation tests, Statistics and Computing, 15, 1, 53-60
}

\seealso{
The permutation spaces on which the test is based: \code{\link{permutationSpace}} function and useful functions associated with that object.

Multiplicity correction: \code{\link{flip.adjust}} and Global test: \code{\link{npc}}.
}

\examples{
Y=matrix(rnorm(50),10,5)
colnames(Y)=LETTERS[1:5]
Y[,1:2]=Y[,1:2] +2
res = flip(Y)
res
plot(res)

X=rep(0:1,5)
Y=Y+matrix(X*2,10,5)

data=data.frame(Y,X=X, Z=rnorm(10))
#testing dependence among Y's and X
(res = flip(Y,~X,data=data))
#same as:
#res = flip(A+B+C+D+E~X,data=data)


#testing dependence among Y's and X, also using covariates
res = flip(Y,~X,~Z,data=data)
res
#Note that 
#flip(Y,X=~X,Z=~1,data=data)
#is different from
#flip(Y,~X,data=data)
#since the former is based on orthogonalized residuals of Y and X by Z.


#Rotation tests:
rot=flip(Y,X,Z=~1,testType="rotation") #deprecated: rotationTest=TRUE
# note the use Z=~1.


#Using rank tests:
res = flip(Y,~X,data=data,statTest="Wilcoxon")
res

#testing symmetry of Y around 0
Y[,1:2]=Y[,1:2] +2
res = flip(Y)
res
plot(res)


#use of strata (in this case equal to paired samples)
data$S=rep(1:5,rep(2,5))
#paired t
flip(A+B+C+D+E~X,data=data,statTest="t",Strata=~S)
#signed Rank test
flip(A+B+C+D+E~X,data=data,statTest="Wilcox",Strata=~S)

# tests for categorical data
data=data.frame(X=rep(0:2,10))
data=data.frame(X=factor(data$X),Y=factor(rbinom(30,2,.2+.2*data$X)))
flip(~Y,~X,data=data,statTest="chisq")
# separated chisq (Finos and Salmaso, 2004. Nonparametric multi-focus analysis 
# for categorical variables. CommStat - T.M.)
(res.sep=flip(~Y,~X,data=data,statTest="chisq.separated"))
npc(res.sep,"sumT2") #note that combined test statistic is the same as chisq


# User-defined test statistic:
my.fun <- function(Y){
  summary(lm(Y~X))$coeff[1,"Pr(>|t|)"]
}
X<- matrix(rep(0:2,10))
Y <- matrix(rnorm(30))
flip(Y=Y,X=X,statTest=my.fun)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{htest}
