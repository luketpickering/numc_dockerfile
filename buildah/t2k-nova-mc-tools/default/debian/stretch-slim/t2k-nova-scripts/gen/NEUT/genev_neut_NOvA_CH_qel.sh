#!/bin/bash

if [ -z $1 ]; then
  echo "Please pass a number of events to generate."
  exit 1
fi

BEAMMODE="FHC"
NU_PDG=14
FLUX_FILE=${NOVANDFLUX_NUMODE_FILE}
FLUX_HIST=${NOVANDFLUX_NUMODE_HIST}
if [ ! -z $2 ] && [ "${2}" == "RHC" ]; then
  echo "Running with "
  NU_PDG=-14
  FLUX_FILE=${NOVANDFLUX_NUBARMODE_FILE}
  FLUX_HIST=${NOVANDFLUX_NUBARMODE_HIST}
  BEAMMODE="RHC"
fi

NEVS=$1
TARG_N=6
TARG_Z=6
TARG_H=1
TARG_A=12
MDLQE=02
CRSPATH=${NEUT_CRSDAT}

if [ -e NOvAND.CH.qel.${BEAMMODE}.neut.root ]; then
   echo "Already have file: NOvAND.CH.qel.${BEAMMODE}.neut.root, not overwriting."
   exit 1
fi

#if it was sourced as . setup.sh then you can't scrub off the end... assume that
#we are in the correct directory.
if ! echo "${BASH_SOURCE}" | grep "/" --silent; then
  SETUPDIR=$(readlink -f $PWD)
else
  SETUPDIR=$(readlink -f ${BASH_SOURCE%/*})
fi

cp ${SETUPDIR}/qel.stub.card NOvAND.CH.qel.${BEAMMODE}.card.cfg
for i in NEVS TARG_N \
         TARG_Z \
         TARG_H \
         TARG_A \
         NU_PDG \
         FLUX_FILE \
         FLUX_HIST \
         MDLQE \
         CRSPATH; do
  sed -i "s|__${i}__|${!i}|g" NOvAND.CH.qel.${BEAMMODE}.card.cfg
done
mv NOvAND.CH.qel.${BEAMMODE}.card.cfg NOvAND.CH.qel.${BEAMMODE}.card

echo "Running neutroot2 NOvAND.CH.qel.${BEAMMODE}.card NOvAND.CH.qel.${BEAMMODE}.neut.root for ${NEVS} events."
neutroot2 NOvAND.CH.qel.${BEAMMODE}.card NOvAND.CH.qel.${BEAMMODE}.neut.root &> /dev/null

if [ -e NOvAND.CH.qel.${BEAMMODE}.neut.root ]; then
   rm -f fort.77 NOvAND.CH.qel.${BEAMMODE}.card

   PrepareNEUT -i NOvAND.CH.qel.${BEAMMODE}.neut.root \
               -f ${FLUX_FILE},${FLUX_HIST} -G
else
   echo "Failed to produce expected output file: NOvAND.CH.qel.${BEAMMODE}.neut.root"
   exit 1
fi
