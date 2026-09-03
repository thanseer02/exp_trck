import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../viewmodels/assistant_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../models/assistant_response.dart';
import '../models/category.dart';

class AssistantView extends StatefulWidget {
  const AssistantView({super.key});

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _suggestions = []; // Replaced by vm.currentSuggestions

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    _focusNode.requestFocus();

    final vm = context.read<AssistantViewModel>();
    
    // Process message and scroll
    await vm.processUserMessage(text);
    
    // Small delay to allow list to rebuild before scrolling
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Money Assistant',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ask me anything about your spending',
              style: TextStyle(
                color: AppColors.textTertiaryDark,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Suggestions strip
            Selector<AssistantViewModel, List<String>>(
              selector: (_, vm) => vm.currentSuggestions,
              builder: (context, suggestions, _) {
                if (suggestions.isEmpty) return const SizedBox.shrink();
                
                return Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 16, bottom: 8),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return ActionChip(
                        backgroundColor: AppColors.surfaceDark,
                        side: const BorderSide(color: AppColors.borderDark),
                        labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                        label: Text(suggestion),
                        onPressed: () => _handleSubmitted(suggestion),
                      );
                    },
                  ),
                );
              },
            ),

            // Chat area
            Expanded(
              child: Selector<AssistantViewModel, int>(
                selector: (_, vm) => vm.chatHistory.length + (vm.isProcessing ? 1 : 0),
                builder: (context, itemCount, _) {
                  final assistantVm = context.read<AssistantViewModel>();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index == assistantVm.chatHistory.length && assistantVm.isProcessing) {
                        return const _TypingIndicator();
                      }
                      
                      final message = assistantVm.chatHistory[index];
                      return _MessageBubble(message: message);
                    },
                  );
                },
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border(
                  top: BorderSide(color: AppColors.borderDark, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: AppColors.textPrimaryDark),
                      decoration: InputDecoration(
                        hintText: 'Ask something...',
                        hintStyle: const TextStyle(color: AppColors.textTertiaryDark),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerHighDark,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AssistantResponse message;
  
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerHighDark,
                  radius: 16,
                  child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceContainerHighDark,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                      bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isUser ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderDark,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          color: message.isError ? AppColors.expense : AppColors.textPrimaryDark,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      
                      // Render structured data if available
                      if ((message.type == AssistantResponseType.amount || message.type == AssistantResponseType.category) && message.amount != null)
                         Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: Text(
                             NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(message.amount),
                             style: const TextStyle(
                               fontSize: 24, 
                               fontWeight: FontWeight.bold, 
                               color: AppColors.textPrimaryDark
                             ),
                           ),
                         ),

                      // Render help groups
                      if (message.type == AssistantResponseType.help && message.helpGroups != null)
                         Padding(
                           padding: const EdgeInsets.only(top: 16.0),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: message.helpGroups!.entries.map((entry) {
                               return Padding(
                                 padding: const EdgeInsets.only(bottom: 12.0),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       entry.key,
                                       style: const TextStyle(
                                         color: AppColors.primary,
                                         fontSize: 12,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                     const SizedBox(height: 8),
                                     Wrap(
                                       spacing: 8,
                                       runSpacing: 8,
                                       children: entry.value.map((example) {
                                         return GestureDetector(
                                           onTap: () {
                                             context.read<AssistantViewModel>().processUserMessage(example);
                                           },
                                           child: Container(
                                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                             decoration: BoxDecoration(
                                               color: AppColors.backgroundDark,
                                               borderRadius: BorderRadius.circular(12),
                                               border: Border.all(color: AppColors.borderDark),
                                             ),
                                             child: Text(
                                               example,
                                               style: const TextStyle(
                                                 color: AppColors.textPrimaryDark,
                                                 fontSize: 13,
                                               ),
                                             ),
                                           ),
                                         );
                                       }).toList(),
                                     ),
                                   ],
                                 ),
                               );
                             }).toList(),
                            ),
                          ),

                       // Render confirmation buttons
                       if (message.type == AssistantResponseType.confirmation && message.confirmPayload != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      final p = message.cancelPayload ?? 'cancel';
                                      context.read<AssistantViewModel>().processUserMessage(p);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textSecondaryDark,
                                      side: const BorderSide(color: AppColors.borderDark),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {
                                      context.read<AssistantViewModel>().processUserMessage('confirmaction ${message.confirmPayload}');
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Confirm'),
                                  ),
                                ),
                              ],
                            ),
                          ),

                       // Render comparison
                      if (message.type == AssistantResponseType.comparison && message.amount != null && message.lastAmount != null)
                         Padding(
                           padding: const EdgeInsets.only(top: 12.0),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               _buildComparisonRow('This month', NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(message.amount!)),
                               const SizedBox(height: 4),
                               _buildComparisonRow('Last month', NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(message.lastAmount!)),
                               const Divider(color: AppColors.borderDark, height: 16),
                               _buildComparisonRow('Difference', '${message.comparisonAmount! > 0 ? '+' : ''}${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(message.comparisonAmount!)}', isBold: true, color: message.comparisonAmount! > 0 ? AppColors.expense : AppColors.income),
                             ],
                           ),
                         ),

                      // Render transactions list
                      if (message.type == AssistantResponseType.transactionList && message.transactions != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: message.transactions!.map((t) {
                              // Lookup category from CategoryViewModel
                              final categoryVm = context.read<CategoryViewModel>();
                              final categories = t.type.name == 'income' 
                                  ? categoryVm.incomeCategories 
                                  : categoryVm.expenseCategories;
                              final category = categories.firstWhere(
                                (c) => c.id == t.categoryId,
                                orElse: () => Category(id: -1, name: 'Unknown', icon: 'category', type: t.type),
                              );
                              
                              final iconData = _getIconData(category.icon);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      iconData,
                                      size: 16,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        category.name,
                                        style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(t.amount),
                                      style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      if (message.actionRoute != null && message.actionLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context, 
                                message.actionRoute!,
                                arguments: message.actionArguments,
                              );
                            },
                            child: Text(message.actionLabel ?? 'Action'),
                          ),
                        )
                    ],
                  ),
                ),
              ),
              
              if (isUser) const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 40,
              right: isUser ? 0 : 40,
            ),
            child: Text(
              DateFormat('h:mm a').format(message.timestamp),
              style: const TextStyle(
                color: AppColors.textTertiaryDark,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? (isBold ? AppColors.textPrimaryDark : AppColors.textSecondaryDark),
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'receipt': return Icons.receipt;
      case 'home': return Icons.home;
      case 'movie': return Icons.movie;
      case 'local_hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'flight': return Icons.flight;
      case 'local_grocery_store': return Icons.local_grocery_store;
      case 'subscriptions': return Icons.subscriptions;
      case 'attach_money': return Icons.attach_money;
      case 'work': return Icons.work;
      case 'business': return Icons.business;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'category':
      default: return Icons.category_outlined;
    }
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHighDark,
            radius: 16,
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighDark,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(color: AppColors.borderDark, width: 1),
            ),
            child: const SizedBox(
              width: 40,
              height: 10,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
