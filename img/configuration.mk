#------------------------------------------------------------------------------#
#                                                                              #
#                                CONFIGURATION                                 #
#                                                                              #
#------------------------------------------------------------------------------#
TARGETS          := datasets
TARGETS_NO_CLEAN := pca
TITLE            := IMAGES

datasets_TITLE   := data set plots
datasets_TARGETS := $(foreach DATASET,$(DATASETS_2D),$(addsuffix .png,$(DATASET)))

pca_TITLE        := PCA plots
pca_TARGETS      := $(foreach DATASET,$(DATASETS),$(addsuffix .png,$(DATASET)))
define pca_NO_CLEAN
-@echo "Let's not delete these figures unless we really have to... it requires a lot of" >&2
-@echo "memory for MATLAB to load the FIG files." >&2
endef

#------------------------------------------------------------------------------#
#                                                                              #
#                          ADDITIONAL DEPENDENCIES                             #
#                                                                              #
#------------------------------------------------------------------------------#
define dataset-dependency
datasets/$(1).png: ../data/datasets/$(1).csv
endef
$(foreach DATASET,$(DATASETS),$(eval $(call dataset-dependency,$(DATASET))))

define pca-dependency
pca/$(1).png: ../data/pca/$(1).fig
endef
$(foreach DATASET,$(DATASETS),$(eval $(call pca-dependency,$(DATASET))))